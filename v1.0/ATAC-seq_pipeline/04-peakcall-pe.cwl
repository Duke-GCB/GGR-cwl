#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0
doc: 'ATAC-seq 04 quantification - PE'
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
   nthreads:
     default: 1
     type: int
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
     run: ../spp/extract-best-frag-length.cwl
     scatter: input_spp_txt_file
     in:
       input_spp_txt_file: spp/output_spp_cross_corr
     out:
     - output_best_frag_length
   peak-calling:
     run: ../peak_calling/macs2-callpeak.cwl
     scatterMethod: dotproduct
     scatter:
     - treatment
     in:
       q:
         valueFrom: ${return 0.1}
       bdg:
         valueFrom: ${return true}
       treatment:
         source: input_bam_files
         valueFrom: $([self])
       g: genome_effective_size
       format:
         valueFrom: BAMPE
     out:
     - output_peak_file
     - output_peak_summits_file
     - output_ext_frag_bdg_file
     - output_peak_xls_file
   count-reads-filtered:
     run: ../peak_calling/count-reads-after-filtering.cwl
     in:
       peak_xls_file: peak-calling/output_peak_xls_file
     scatter: peak_xls_file
     out:
     - read_count_file
   count-peaks:
     run: ../utils/count-with-output-suffix.cwl
     in:
       output_suffix:
         valueFrom: .peak_count.within_replicate.txt
       input_file: peak-calling/output_peak_file
     scatter: input_file
     out:
     - output_counts
   filter-reads-in-peaks:
     run: ../peak_calling/samtools-filter-in-bedfile.cwl
     scatterMethod: dotproduct
     scatter:
     - input_bam_file
     - input_bedfile
     in:
       input_bam_file: input_bam_files
       input_bedfile: peak-calling/output_peak_file
     out:
     - filtered_file
   extract-count-reads-in-peaks:
     run: ../peak_calling/samtools-extract-number-mapped-reads.cwl
     scatter: input_bam_file
     in:
       output_suffix:
         valueFrom: .read_count.within_replicate.txt
       input_bam_file: filter-reads-in-peaks/filtered_file
     out:
     - output_read_count
   trunk-peak-score:
     run: ../utils/trunk-peak-score.cwl
     scatter: peaks
     in:
       peaks: peak-calling/output_peak_file
     out:
     - trunked_scores_peaks
   peaks-bed-to-bigbed:
     run: ../quant/bedToBigBed.cwl
     in:
       type:
         valueFrom: bed6+4
       as: as_narrowPeak_file
       genome_sizes: input_genome_sizes
       bed: trunk-peak-score/trunked_scores_peaks
     scatter: bed
     out:
     - bigbed
   sort-bam-by-name:
     run: ../map/samtools-sort.cwl
     scatter: input_file
     in:
       n:
         valueFrom: ${return true}
       nthreads: nthreads
       input_file: input_bam_files
     out:
     - sorted_file
   bedtools_bamtobed:
     run: ../map/bedtools-bamtobed.cwl
     scatter: bam
     in:
       bam: sort-bam-by-name/sorted_file
       bedpe:
         valueFrom: ${return true}
     out:
     - output_bedfile
   unpair_bedpe:
     run: ../peak_calling/bedpe-to-bed.cwl
     scatter: bedpe
     in:
       bedpe: bedtools_bamtobed/output_bedfile
     out:
     - bed
   peak-calling-unpaired:
     run: ../peak_calling/macs2-callpeak.cwl
     scatter: treatment
     in:
       treatment:
         source: unpair_bedpe/bed
         valueFrom: $([self])
       extsize:
         valueFrom: ${return 200}
       bdg:
         valueFrom: ${return true}
       nomodel:
         valueFrom: ${return true}
       g: genome_effective_size
       format:
         valueFrom: BED
       shift:
         valueFrom: ${return -100}
       q:
         valueFrom: ${return 0.1}
     out:
     - output_peak_file
     - output_peak_summits_file
     - output_ext_frag_bdg_file
     - output_peak_xls_file
   count-reads-filtered-unpaired:
     run: ../peak_calling/count-reads-after-filtering.cwl
     scatter: peak_xls_file
     in:
       peak_xls_file: peak-calling-unpaired/output_peak_xls_file
     out:
     - read_count_file
   count-peaks-unpaired:
     run: ../utils/count-with-output-suffix.cwl
     scatter: input_file
     in:
       output_suffix:
         valueFrom: .peak_count.within_replicate.txt
       input_file: peak-calling-unpaired/output_peak_file
     out:
     - output_counts
   filter-reads-in-peaks-unpaired:
     run: ../peak_calling/samtools-filter-in-bedfile.cwl
     scatterMethod: dotproduct
     scatter:
     - input_bam_file
     - input_bedfile
     in:
       input_bam_file: input_bam_files
       input_bedfile: peak-calling-unpaired/output_peak_file
     out:
     - filtered_file
   trunk-peak-score-unpaired:
     run: ../utils/trunk-peak-score.cwl
     in:
       peaks: peak-calling-unpaired/output_peak_file
     scatter: peaks
     out:
     - trunked_scores_peaks
   clip-off-chrom:
     run: ../quant/bedClip.cwl
     in:
       bed_file: trunk-peak-score-unpaired/trunked_scores_peaks
       genome_sizes: input_genome_sizes
       output_suffix:
         valueFrom: .narrowPeak
     scatter: bed_file
     out:
     - bed_file_clipped
   peaks-bed-to-bigbed-unpaired:
     run: ../quant/bedToBigBed.cwl
     in:
       type:
         valueFrom: bed6+4
       as: as_narrowPeak_file
       genome_sizes: input_genome_sizes
       bed: clip-off-chrom/bed_file_clipped
     scatter: bed
     out:
     - bigbed
outputs:
   output_filtered_read_count_file:
     doc: Filtered read count reported by MACS2
     type: File[]
     outputSource: count-reads-filtered/read_count_file
   output_peak_summits_file:
     doc: File containing peak summits
     type: File[]
     outputSource: peak-calling/output_peak_summits_file
   output_peak_file:
     doc: peakshift/phantomPeak results file
     type: File[]
     outputSource: peak-calling/output_peak_file
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
   output_extended_peak_file:
     doc: peakshift/phantomPeak extended fragment results file
     type: File[]
     outputSource: peak-calling/output_ext_frag_bdg_file
   output_peak_xls_file:
     doc: Peak calling report file (*_peaks.xls file produced by MACS2)
     type: File[]
     outputSource: peak-calling/output_peak_xls_file
   output_peak_bigbed_file:
     doc: Peaks in bigBed format
     type: File[]
     outputSource: peaks-bed-to-bigbed/bigbed
   output_read_in_peak_count_within_replicate:
     doc: Reads peak counts within replicate
     type: File[]
     outputSource: extract-count-reads-in-peaks/output_read_count
   output_unpaired_peak_xls_file:
     doc: Peak calling report file (*_peaks.xls file produced by MACS2) using each paired mate independently
     type: File[]
     outputSource: peak-calling-unpaired/output_peak_xls_file
   output_unpaired_filtered_read_count_file:
     doc: Filtered read count reported by MACS2 using each paired mate independently
     type: File[]
     outputSource: count-reads-filtered-unpaired/read_count_file
   output_unpaired_peak_count_within_replicate:
     doc: Peak counts within replicate using each paired mate independently
     type: File[]
     outputSource: count-peaks-unpaired/output_counts
   output_unpaired_peak_summits_file:
     doc: File containing peak summits using each paired mate independently
     type: File[]
     outputSource: peak-calling-unpaired/output_peak_summits_file
   output_unpaired_peak_bigbed_file:
     doc: Peaks in bigBed format using each paired mate independently
     type: File[]
     outputSource: peaks-bed-to-bigbed-unpaired/bigbed
   output_unpaired_extended_peak_file:
     doc: peakshift/phantomPeak extended fragment results file using each paired mate independently
     type: File[]
     outputSource: peak-calling-unpaired/output_ext_frag_bdg_file
   output_unpaired_peak_file:
     doc: peakshift/phantomPeak results file using each paired mate independently
     type: File[]
     outputSource: peak-calling-unpaired/output_peak_file