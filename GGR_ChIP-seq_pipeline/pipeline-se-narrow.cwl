#!/usr/bin/env cwl-runner
class: Workflow
description: "GGR_ChIP-seq pipeline - reads: SE, region: narrow, samples: treatment."
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
  - id: "#nthreads_qc"
    type: int
    description: "Numbers of threads required for the 01-qc step"
  - id: "#nthreads_trimm"
    type: int
    description: "Numbers of threads required for the 02-trim step"
  - id: "#nthreads_map"
    type: int
    description: "Numbers of threads required for the 03-map step"
outputs:
  - id: "#qc_raw_read_counts"
    source: "#qc.output_raw_read_counts"
    description: "Raw read counts of fastq files after QC"
    type:
      type: array
      items: File
  - id: "#trimm_raw_read_counts"
    source: "#trimm.trimmed_fastq_read_count"
    description: "Raw read counts of fastq files after TRIMM"
    type:
      type: array
      items: File
  - id: "#trimm_fastq_files"
    source: "#trimm.output_data_fastq_trimmed_files"
    description: "FASTQ files after trimming step"
    type:
      type: array
      items: File
  - id: "#map_mark_duplicates_files"
    source: "#map.output_picard_mark_duplicates_files"
    description: "Summary of duplicates removed with Picard tool MarkDuplicates (for multiple reads aligned to the same positions"
    type:
      type: array
      items: File
  - id: "#map_dedup_bam_files"
    source: "#map.output_data_sorted_dedup_bam_files"
    description: "Filtered BAM files (post-processing end point)"
    type:
      type: array
      items: File
  - id: "#map_dedup_bam_index_files"
    source: "#map.output_index_dedup_bam_files"
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
  - id: "#qc"
    run: {import: "processing_step1/01-qc-se.cwl" }
    inputs:
      - { id: "#qc.input_fastq_files", source: "#input_fastq_files" }
      - { id: "#qc.default_adapters_file", source: "#default_adapters_file" }
      - { id: "#qc.nthreads", source: "#nthreads_qc" }
    outputs:
      - { id:  "#qc.output_raw_read_counts" }
      - { id:  "#qc.output_fastqc_read_counts" }
      - { id:  "#qc.output_fastqc_report_files" }
      - { id:  "#qc.output_fastqc_data_files" }
      - { id:  "#qc.output_custom_adapters" }
  - id: "#trimm"
    run: {import: "processing_step1/02-trim-se.cwl" }
    inputs:
      - { id: "#trimm.input_fastq_files", source: "#input_fastq_files" }
      - { id: "#trimm.input_adapters_files", source: "#qc.output_custom_adapters" }
      - { id: "#trimm.nthreads", source: "#nthreads_trimm" }
    outputs:
      - { id:  "#trimm.output_data_fastq_trimmed_files" }
      - { id:  "#trimm.trimmed_fastq_read_count" }
  - id: "#map"
    run: {import: "processing_step1/03-map-se.cwl" }
    inputs:
      - { id: "#map.input_fastq_files", source: "#trimm.output_data_fastq_trimmed_files" }
      - { id: "#map.genome_ref_first_index_file", source: "#genome_ref_first_index_file" }
      - { id: "#map.genome_sizes_file", source: "#genome_sizes_file" }
      - { id: "#map.ENCODE_blacklist_bedfile", source: "#ENCODE_blacklist_bedfile" }
      - { id: "#map.nthreads", source: "#nthreads_map" }
    outputs:
      - { id:  "#map.output_data_sorted_dedup_bam_files" }
      - { id:  "#map.output_index_dedup_bam_files" }
      - { id:  "#map.output_picard_mark_duplicates_files" }
      - { id:  "#map.output_pbc_files" }
  - id: "#peak_call"
    run: {import: "processing_step2/01-peakcall-narrow-.cwl" }
    inputs:
      - { id: "#peak_call.input_bam_files", source: "#map.output_data_sorted_dedup_bam_files" }
      - { id: "#peak_call.input_bam_format", valueFrom: "BAM" }
    outputs:
      - { id: "#peak_call.output_spp_x_cross_corr" }
      - { id: "#peak_call.output_spp_cross_corr_plot" }
      - { id: "#peak_call.output_narrowpeak_file" }
      - { id: "#peak_call.output_extended_narrowpeak_file" }
      - { id: "#peak_call.output_peak_xls_file" }
      - { id: "#peak_call.output_filtered_read_count_file" }
      - { id: "#peak_call.output_peak_count_within_replicate" }
      - { id: "#peak_call.output_read_in_peak_count_within_replicate" }
  - id: "#quant"
    run: {import: "processing_step2/02-quantification.cwl" }
    inputs:
      - { id: "#quant.input_bam_files", source: "#map.output_data_sorted_dedup_bam_files" }
      - { id: "#quant.input_pileup_bedgraphs", source: "#peak_call.output_extended_narrowpeak_file" }
      - { id: "#quant.input_peak_xls_files", source: "#peak_call.output_peak_xls_file" }
      - { id: "#quant.input_read_count_dedup_files", source: "#peak_call.output_read_in_peak_count_within_replicate" }
      - { id: "#quant.input_genome_sizes", source: "#genome_sizes_file" }
    outputs:
      - { id: "#quant.bigwig_raw_files" }
      - { id: "#quant.bigwig_norm_files" }
      - { id: "#quant.bigwig_extended_files" }
      - { id: "#quant.bigwig_extended_norm_files" }