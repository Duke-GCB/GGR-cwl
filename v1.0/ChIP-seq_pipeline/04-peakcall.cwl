#!/usr/bin/env cwl-runner
 class: Workflow
 cwlVersion: v1.0
 doc: 'ChIP-seq 04 quantification - samples: treatment.'
 requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
 inputs:
    input_bam_files:
      type: File[]
    genome_effective_size:
      default: hs
      doc: Effective genome size used by MACS2. It can be numeric or a shortcuts:'hs' for human (2.7e9), 'mm' for mouse (1.87e9), 'ce' for C. elegans (9e7) and 'dm' for fruitfly (1.2e8), Default:hs
      type: string
    input_genome_sizes:
      doc: Two column tab-delimited file with chromosome size information
      type: File
    as_narrowPeak_file:
      doc: Definition narrowPeak file in AutoSql format (used in bedToBigBed)
      type: File
    as_broadPeak_file:
      doc: Definition broadPeak file in AutoSql format (used in bedToBigBed)
      type: File
    nthreads:
      default: 1
      type: int
 outputs:
    output_filtered_read_count_file:
      doc: Filtered read count reported by MACS2
      type: File[]
      outputSource: count-reads-filtered/read_count_file
    output_spp_cross_corr_plot:
      doc: peakshift/phantomPeak results file
      type: File[]
      outputSource: spp/output_spp_cross_corr_plot
    output_spp_x_cross_corr:
      doc: peakshift/phantomPeak results file
      type: File[]
      outputSource: spp/output_spp_cross_corr
    output_narrowpeak_count:
      doc: Peak counts within replicate
      type: File[]
      outputSource: count-narrowpeaks/output_counts
    output_read_in_narrowpeak_count_within_replicate:
      doc: narrowPeak counts within replicate
      type: File[]
      outputSource: extract-count-reads-in-narrowpeaks/output_read_count
    output_narrowpeak_file:
      doc: peakshift/phantomPeak results file
      type: File[]
      outputSource: narrowPeak-calling/output_peak_file
    output_narrowpeak_bigbed_file:
      doc: Peaks in bigBed format
      type: File[]
      outputSource: narrowpeaks-bed-to-bigbed/bigbed
    output_narrowpeak_xls_file:
      doc: Peak calling report file (*_peaks.xls file produced by MACS2)
      type: File[]
      outputSource: narrowPeak-calling/output_peak_xls_file
    output_narrowpeak_summits_file:
      doc: File containing peak summits
      type:
        type: array
        items:
        - 'null'
        - items: File
          type: array
      outputSource: narrowPeak-calling/output_peak_summits_file
    output_broadpeak_count:
      doc: Peak counts within replicate
      type: File[]
      outputSource: count-broadpeaks/output_counts
    output_read_in_broadpeak_count_within_replicate:
      doc: broadPeak counts within replicate
      type: File[]
      outputSource: extract-count-reads-in-broadpeaks/output_read_count
    output_broadpeak_file:
      doc: peakshift/phantomPeak results file
      type: File[]
      outputSource: broadPeak-calling/output_peak_file
    output_broadpeak_bigbed_file:
      doc: Peaks in bigBed format
      type: File[]
      outputSource: broadpeaks-bed-to-bigbed/bigbed
    output_broadpeak_xls_file:
      doc: Peak calling report file (*_peaks.xls file produced by MACS2)
      type: File[]
      outputSource: broadPeak-calling/output_peak_xls_file
    output_broadpeak_summits_file:
      doc: File containing peak summits
      type:
        type: array
        items:
        - 'null'
        - items: File
          type: array
      outputSource: broadPeak-calling/output_peak_summits_file
 steps:
    spp:
      run: ../spp/spp.cwl
      scatterMethod: dotproduct
      scatter:
      - input_bam
      in:
        input_bam: input_bam_files
        nthreads: nthreads
        savp:
          valueFrom: ${return true}
      out:
      - output_spp_cross_corr
      - output_spp_cross_corr_plot
    extract-peak-frag-length:
      scatter: input_spp_txt_file
      run: ../spp/extract-best-frag-length.cwl
      in:
        input_spp_txt_file: spp/output_spp_cross_corr
      out:
      - output_best_frag_length
    narrowPeak-calling:
      run: ../peak_calling/macs2-callpeak.cwl
      scatterMethod: dotproduct
      scatter:
      - extsize
      - treatment
      in:
        treatment:
          source: input_bam_files
          valueFrom: $([self])
        extsize: extract-peak-frag-length/output_best_frag_length
        nomodel:
          valueFrom: ${return true}
        g: genome_effective_size
        format:
          valueFrom: BAM
      out:
      - output_peak_file
      - output_peak_summits_file
      - output_peak_xls_file
    trunk-narrowpeak-score:
      scatter: peaks
      run: ../utils/trunk-peak-score.cwl
      in:
        peaks: narrowPeak-calling/output_peak_file
      out:
      - trunked_scores_peaks
    narrowpeaks-bed-to-bigbed:
      run: ../quant/bedToBigBed.cwl
      scatter: bed
      in:
        type:
          valueFrom: bed6+4
        as: as_narrowPeak_file
        genome_sizes: input_genome_sizes
        bed: trunk-narrowpeak-score/trunked_scores_peaks
      out:
      - bigbed
    filter-reads-in-narrowpeaks:
      scatterMethod: dotproduct
      scatter:
      - input_bam_file
      - input_bedfile
      run: ../peak_calling/samtools-filter-in-bedfile.cwl
      in:
        input_bam_file: input_bam_files
        input_bedfile: narrowPeak-calling/output_peak_file
      out:
      - filtered_file
    extract-count-reads-in-narrowpeaks:
      run: ../peak_calling/samtools-extract-number-mapped-reads.cwl
      scatter: input_bam_file
      in:
        output_suffix:
          valueFrom: .read_count.in_narrowpeaks.txt
        input_bam_file: filter-reads-in-narrowpeaks/filtered_file
      out:
      - output_read_count
    count-narrowpeaks:
      run: ../utils/count-with-output-suffix.cwl
      scatter: input_file
      in:
        output_suffix:
          valueFrom: .peak_count.within_replicate.txt
        input_file: narrowPeak-calling/output_peak_file
      out:
      - output_counts
    broadPeak-calling:
      run: ../peak_calling/macs2-callpeak.cwl
      scatterMethod: dotproduct
      scatter:
      - extsize
      - treatment
      in:
        treatment:
          source: input_bam_files
          valueFrom: $([self])
        extsize: extract-peak-frag-length/output_best_frag_length
        nomodel:
          valueFrom: ${return true}
        g: genome_effective_size
        format:
          valueFrom: BAM
        broad:
            valueFrom: ${return true}
      out:
      - output_peak_file
      - output_peak_summits_file
      - output_peak_xls_file
    trunk-broadpeak-score:
      scatter: peaks
      run: ../utils/trunk-peak-score.cwl
      in:
        peaks: broadPeak-calling/output_peak_file
      out:
      - trunked_scores_peaks
    broadpeaks-bed-to-bigbed:
      run: ../quant/bedToBigBed.cwl
      scatter: bed
      in:
        type:
          valueFrom: bed6+4
        as: as_broadPeak_file
        genome_sizes: input_genome_sizes
        bed: trunk-broadpeak-score/trunked_scores_peaks
      out:
      - bigbed
    filter-reads-in-broadpeaks:
      scatterMethod: dotproduct
      scatter:
      - input_bam_file
      - input_bedfile
      run: ../peak_calling/samtools-filter-in-bedfile.cwl
      in:
        input_bam_file: input_bam_files
        input_bedfile: broadPeak-calling/output_peak_file
      out:
      - filtered_file
    extract-count-reads-in-broadpeaks:
      run: ../peak_calling/samtools-extract-number-mapped-reads.cwl
      scatter: input_bam_file
      in:
        output_suffix:
          valueFrom: .read_count.in_broadpeaks.txt
        input_bam_file: filter-reads-in-broadpeaks/filtered_file
      out:
      - output_read_count
    count-broadpeaks:
      run: ../utils/count-with-output-suffix.cwl
      scatter: input_file
      in:
        output_suffix:
          valueFrom: .peak_count.within_replicate.txt
        input_file: broadPeak-calling/output_peak_file
      out:
      - output_counts
    count-reads-filtered:
      run: ../peak_calling/count-reads-after-filtering.cwl
      scatter: peak_xls_file
      in:
        peak_xls_file: narrowPeak-calling/output_peak_xls_file
      out:
      - read_count_file