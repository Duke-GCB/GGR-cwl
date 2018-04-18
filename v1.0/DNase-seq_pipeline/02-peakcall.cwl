 class: Workflow
 cwlVersion: v1.0
 doc: DNase-seq 02 quantification
 requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
 inputs:
    input_bam_format:
      default: BAM
      doc: 'BAM or BAMPE for single-end and paired-end reads respectively (default: BAM)'
      type: string
    input_bam_files:
      type: File[]
    nthreads:
      default: 1
      type: int
 steps:
    peak-calling-narrow:
      run: ../peak_calling/macs2-callpeak.cwl
      in:
        extsize:
          valueFrom: ${return 200}
        bdg:
          valueFrom: ${return true}
        nomodel:
          valueFrom: ${return true}
        format: input_bam_format
        shift:
          valueFrom: ${return -100}
        q:
          valueFrom: ${return 0.10}
        treatment:
          source: input_bam_files
          valueFrom: $([self])
      scatter:
      - treatment
      out:
      - output_peak_file
      - output_ext_frag_bdg_file
      - output_peak_xls_file
    count-reads-filtered:
      run: ../peak_calling/count-reads-after-filtering.cwl
      in:
        peak_xls_file: peak-calling-narrow/output_peak_xls_file
      scatter: peak_xls_file
      out:
      - read_count_file
    spp:
      run: ../spp/spp.cwl
      in:
        input_bam: input_bam_files
        nthreads: nthreads
        savp:
          valueFrom: ${return true}
      scatterMethod: dotproduct
      scatter:
      - input_bam
      out:
      - output_spp_cross_corr
      - output_spp_cross_corr_plot
    extract-peak-frag-length:
      run: ../spp/extract-best-frag-length.cwl
      in:
        input_spp_txt_file: spp/output_spp_cross_corr
      scatter: input_spp_txt_file
      out:
      - output_best_frag_length
    extract-count-reads-in-peaks:
      run: ../peak_calling/samtools-extract-number-mapped-reads.cwl
      in:
        output_suffix:
          valueFrom: .read_count.in_peaks.within_reps.txt
        input_bam_file: filter-reads-in-peaks/filtered_file
      scatter: input_bam_file
      out:
      - output_read_count
    filter-reads-in-peaks:
      run: ../peak_calling/samtools-filter-in-bedfile.cwl
      in:
        input_bam_file: input_bam_files
        input_bedfile: peak-calling-narrow/output_peak_file
      scatterMethod: dotproduct
      scatter:
      - input_bam_file
      - input_bedfile
      out:
      - filtered_file
    count-peaks:
      run: ../utils/count-with-output-suffix.cwl
      in:
        output_suffix:
          valueFrom: .peak_count.within_replicate.txt
        input_file: peak-calling-narrow/output_peak_file
      scatter: input_file
      out:
      - output_counts
 outputs:
    output_filtered_read_count_file:
      doc: Filtered read count reported by MACS2
      type: File[]
      outputSource: count-reads-filtered/read_count_file
    output_extended_narrowpeak_file:
      doc: peakshift/phantomPeak extended fragment results file
      type: File[]
      outputSource: peak-calling-narrow/output_ext_frag_bdg_file
    output_narrowpeak_file:
      doc: peakshift/phantomPeak results file
      type: File[]
      outputSource: peak-calling-narrow/output_peak_file
    output_peak_count_within_replicate:
      doc: Peak counts within replicate
      type: File[]
      outputSource: count-peaks/output_counts
    output_spp_cross_corr_plot:
      doc: peakshift/phantomPeak results file
      type: File[]
      outputSource: spp/output_spp_cross_corr_plot
    output_spp_x_cross_corr:
      doc: peakshift/phantomPeak results file
      type: File[]
      outputSource: spp/output_spp_cross_corr
    output_peak_xls_file:
      doc: Peak calling report file (*_peaks.xls file produced by MACS2)
      type: File[]
      outputSource: peak-calling-narrow/output_peak_xls_file
    output_read_in_peak_count_within_replicate:
      doc: Peak counts within replicate
      type: File[]
      outputSource: extract-count-reads-in-peaks/output_read_count
