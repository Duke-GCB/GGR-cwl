#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "DNase-seq pipeline - reads: SE"
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
inputs:
  - id: "#input_fastq_files"
    type:
      type: array
      items: File
  - id: "#default_adapters_file"
    type: File
    description: "Adapters file"
  - id: "#genome_ref_first_index_file"
    type: File
    description: |
        "First index file of Bowtie reference genome with extension 1.ebwt. \
        (Note: the rest of the index files MUST be in the same folder)"
  - id: "#genome_sizes_file"
    type: File
    description: "Genome sizes tab-delimited file (used in samtools)"
  - id: "#ENCODE_blacklist_bedfile"
    type: File
    description: "Bedfile containing ENCODE consensus blacklist regions to be excluded."
  - id: "#nthreads_map"
    type: int
    description: "Number of threads required for the 03-map step"
  - id: "#nthreads_peakcall"
    type: int
    description: "Number of threads required for the 04-peakcall step"
  - id: "#nthreads_quant"
    type: int
    description: "Number of threads required for the 05-quantification step"
outputs:
  - id: "#fastq_read_count"
    source: "#map.original_fastq_read_count"
    description: "Read counts of the (unprocessed) input fastq files"
    type:
      type: array
      items: File
  - id: "#map_read_count"
    source: "#map.output_read_count_mapped"
    description: "Read counts of the mapped BAM files"
    type:
      type: array
      items: File
  - id: "#map_filtered_read_count"
    source: "#map.output_read_count_mapped_filtered"
    description: "Read counts of the mapped and filtered BAM files"
    type:
      type: array
      items: File
  - id: "#map_percentage_uniq_reads"
    source: "#map.output_percentage_uniq_reads"
    description: "Percentage of uniq reads from preseq c_curve output"
    type:
      type: array
      items: File
  - id: "#map_filtered_bam_files"
    source: "#map.output_data_filtered_bam_files"
    description: "Filtered BAM files (post-processing end point)"
    type:
      type: array
      items: File
  - id: "#map_dedup_bam_index_files"
    source: "#map.output_index_filtered_bam_files"
    description: "Filtered BAM index files"
    type:
      type: array
      items: File
  - id: "#map_pbc_files"
    source: "#map.output_pbc_files"
    description: "PCR Bottleneck Coefficient files (used to flag samples when pbc<0.5)"
    type:
      type: array
      items: File
  - id: "#map_preseq_c_curve_files"
    source: "#map.output_preseq_c_curve_files"
    description: "Preseq c_curve output files"
    type:
      type: array
      items: File
  - id: "#map_bowtie_log_files"
    source: "#map.output_bowtie_log"
    description: "Bowtie log file with mapping stats"
    type:
      type: array
      items: File
  - id: "#peak_call_spp_x_cross_corr"
    source: "#peak_call.output_spp_x_cross_corr"
    description: "SPP strand cross correlation summary"
    type:
      type: array
      items: File
  - id: "#peak_call_spp_x_cross_corr_plot"
    source: "#peak_call.output_spp_cross_corr_plot"
    description: "SPP strand cross correlation plot"
    type:
      type: array
      items: File
  - id: "#peak_call_peak_xls_file"
    source: "#peak_call.output_peak_xls_file"
    description: "Peak calling report file"
    type:
      type: array
      items: File
  - id: "#peak_call_filtered_read_count_file"
    source: "#peak_call.output_filtered_read_count_file"
    description: "Filtered read count after peak calling"
    type:
      type: array
      items: File
  - id: "#peak_call_read_in_peak_count_within_replicate"
    source: "#peak_call.output_read_in_peak_count_within_replicate"
    description: "Peak counts within replicate"
    type:
      type: array
      items: File
  - id: "#peak_call_peak_count_within_replicate"
    source: "#peak_call.output_peak_count_within_replicate"
    description: "Peak counts within replicate"
    type:
      type: array
      items: File
  - id: "#peak_call_narrowpeak_file"
    source: "#peak_call.output_narrowpeak_file"
    description: "Peaks in narrowPeak file format"
    type:
      type: array
      items: File
  - id: "#peak_call_extended_narrowpeak_file"
    source: "#peak_call.output_extended_narrowpeak_file"
    description: "Extended fragment peaks in narrowPeak file format"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_raw_files"
    source: "#quant.bigwig_raw_files"
    description: "Raw reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_norm_files"
    source: "#quant.bigwig_norm_files"
    description: "Normalized reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_extended_files"
    source: "#quant.bigwig_extended_files"
    description: "Fragment extended reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_extended_norm_files"
    source: "#quant.bigwig_extended_norm_files"
    description: "Normalized fragment extended reads bigWig (signal) files"
    type:
      type: array
      items: File
steps:
  - id: "#map"
    run: {$import: "01-map-se.cwl" }
    inputs:
      - { id: "#map.input_fastq_files", source: "#input_fastq_files" }
      - { id: "#map.genome_ref_first_index_file", source: "#genome_ref_first_index_file" }
      - { id: "#map.genome_sizes_file", source: "#genome_sizes_file" }
      - { id: "#map.ENCODE_blacklist_bedfile", source: "#ENCODE_blacklist_bedfile" }
      - { id: "#map.nthreads", source: "#nthreads_map" }
    outputs:
      - { id: "#map.output_data_filtered_bam_files" }
      - { id: "#map.output_index_filtered_bam_files" }
      - { id: "#map.output_pbc_files" }
      - { id: "#map.output_bowtie_log" }
      - { id: "#map.output_preseq_c_curve_files" }
      - { id: "#map.original_fastq_read_count" }
      - { id: "#map.output_read_count_mapped" }
      - { id: "#map.output_read_count_mapped_filtered" }
      - { id: "#map.output_percentage_uniq_reads" }
  - id: "#peak_call"
    run: {$import: "02-peakcall.cwl" }
    inputs:
      - { id: "#peak_call.input_bam_files", source: "#map.output_data_filtered_bam_files" }
      - { id: "#peak_call.input_bam_format", valueFrom: "BAM" }
      - { id: "#peak_call.nthreads", source: "#nthreads_peakcall" }
    outputs:
      - { id: "#peak_call.output_spp_x_cross_corr" }
      - { id: "#peak_call.output_spp_cross_corr_plot" }
      - { id: "#peak_call.output_peak_file" }
      - { id: "#peak_call.output_extended_narrowpeak_file" }
      - { id: "#peak_call.output_peak_xls_file" }
      - { id: "#peak_call.output_filtered_read_count_file" }
      - { id: "#peak_call.output_peak_count_within_replicate" }
      - { id: "#peak_call.output_read_in_peak_count_within_replicate" }
  - id: "#quant"
    run: {$import: "03-quantification.cwl" }
    inputs:
      - { id: "#quant.input_bam_files", source: "#map.output_data_filtered_bam_files" }
      - { id: "#quant.input_pileup_bedgraphs", source: "#peak_call.output_extended_narrowpeak_file" }
      - { id: "#quant.input_peak_xls_files", source: "#peak_call.output_peak_xls_file" }
      - { id: "#quant.input_read_count_dedup_files", source: "#peak_call.output_read_in_peak_count_within_replicate" }
      - { id: "#quant.input_genome_sizes", source: "#genome_sizes_file" }
      - { id: "#quant.nthreads", source: "#nthreads_quant" }
    outputs:
      - { id: "#quant.bigwig_raw_files" }
      - { id: "#quant.bigwig_norm_files" }
      - { id: "#quant.bigwig_extended_files" }
      - { id: "#quant.bigwig_extended_norm_files" }