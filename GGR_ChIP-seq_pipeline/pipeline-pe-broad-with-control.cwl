#!/usr/bin/env cwl-runner
class: Workflow
description: "GGR_ChIP-seq pipeline - reads: PE, region: broad, samples: treatment and control."
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  - id: "#input_treatment_fastq_read1_files"
    type:
      type: array
      items: File
    description: "Input treatment fastq paired-end read 1 files"
  - id: "#input_treatment_fastq_read2_files"
    type:
      type: array
      items: File
    description: "Input treatment fastq paired-end read 2 files"
  - id: "#input_control_fastq_read1_files"
    type:
      type: array
      items: File
    description: "Input control fastq paired-end read 1 files"
  - id: "#input_control_fastq_read2_files"
    type:
      type: array
      items: File
    description: "Input control fastq paired-end read 2 files"
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
  - id: "#qc_treatment_count_raw_reads_read1"
    source: "#qc_treatment.output_count_raw_reads_read1"
    description: "Raw read counts of fastq files for read 1 after QC for treatment"
    type:
      type: array
      items: File
  - id: "#qc_treatment_count_raw_reads_read2"
    source: "#qc_treatment.output_count_raw_reads_read2"
    description: "Raw read counts of fastq files for read 2 after QC for treatment"
    type:
      type: array
      items: File
  - id: "#qc_treatment_diff_counts_read1"
    source: "#qc_treatment.output_diff_counts_read1"
    description: "Diff file between number of raw reads and number of reads counted by FASTQC, read 1 for treatment"
    type:
      type: array
      items: File
  - id: "#qc_treatment_diff_counts_read2"
    source: "#qc_treatment.output_diff_counts_read2"
    description: "Diff file between number of raw reads and number of reads counted by FASTQC, read 2 for treatment"
    type:
      type: array
      items: File
  - id: "#trimm_treatment_raw_counts_read1"
    source: "#trimm_treatment.output_trimmed_read1_fastq_read_count"
    description: "Raw read counts for R1 of fastq files after TRIMM for treatment"
    type:
      type: array
      items: File
  - id: "#trimm_treatment_raw_counts_read2"
    source: "#trimm_treatment.output_trimmed_read2_fastq_read_count"
    description: "Raw read counts for R2 of fastq files after TRIMM for treatment"
    type:
      type: array
      items: File
  - id: "#trimm_treatment_fastq_files_read1"
    source: "#trimm_treatment.output_data_fastq_read1_trimmed_files"
    description: "FASTQ files after trimming step for treatment"
    type:
      type: array
      items: File
  - id: "#trimm_treatment_fastq_files_read2"
    source: "#trimm_treatment.output_data_fastq_read2_trimmed_files"
    description: "FASTQ files after trimming step for treatment"
    type:
      type: array
      items: File
  - id: "#map_treatment_mark_duplicates_files"
    source: "#map_treatment.output_picard_mark_duplicates_files"
    description: "Summary of duplicates removed with Picard tool MarkDuplicates (for multiple reads aligned to the same positions) for treatment"
    type:
      type: array
      items: File
  - id: "#map_treatment_dedup_bam_files"
    source: "#map_treatment.output_data_sorted_dedup_bam_files"
    description: "Filtered BAM files (post-processing end point) for treatment"
    type:
      type: array
      items: File
  - id: "#map_treatment_dedup_bam_index_files"
    source: "#map_treatment.output_index_dedup_bam_files"
    description: "Filtered BAM index files for treatment"
    type:
      type: array
      items: File
  - id: "#map_treatment_pbc_files"
    source: "#map_treatment.output_pbc_files"
    description: "PCR Bottleneck Coefficient files (used to flag samples when pbc<0.5) for treatment"
    type:
      type: array
      items: File
  - id: "#qc_control_count_raw_reads_read1"
    source: "#qc_control.output_count_raw_reads_read1"
    description: "Raw read counts of fastq files for read 1 after QC for control"
    type:
      type: array
      items: File
  - id: "#qc_control_count_raw_reads_read2"
    source: "#qc_control.output_count_raw_reads_read2"
    description: "Raw read counts of fastq files for read 2 after QC for control"
    type:
      type: array
      items: File
  - id: "#qc_control_diff_counts_read1"
    source: "#qc_control.output_diff_counts_read1"
    description: "Diff file between number of raw reads and number of reads counted by FASTQC, read 1 for control"
    type:
      type: array
      items: File
  - id: "#qc_control_diff_counts_read2"
    source: "#qc_control.output_diff_counts_read2"
    description: "Diff file between number of raw reads and number of reads counted by FASTQC, read 2 for control"
    type:
      type: array
      items: File
  - id: "#trimm_control_raw_counts_read1"
    source: "#trimm_control.output_trimmed_read1_fastq_read_count"
    description: "Raw read counts for R1 of fastq files after TRIMM for control"
    type:
      type: array
      items: File
  - id: "#trimm_control_raw_counts_read2"
    source: "#trimm_control.output_trimmed_read2_fastq_read_count"
    description: "Raw read counts for R2 of fastq files after TRIMM for control"
    type:
      type: array
      items: File
  - id: "#trimm_control_fastq_files_read1"
    source: "#trimm_control.output_data_fastq_read1_trimmed_files"
    description: "FASTQ files after trimming step for control"
    type:
      type: array
      items: File
  - id: "#trimm_control_fastq_files_read2"
    source: "#trimm_control.output_data_fastq_read2_trimmed_files"
    description: "FASTQ files after trimming step for control"
    type:
      type: array
      items: File
  - id: "#map_control_mark_duplicates_files"
    source: "#map_control.output_picard_mark_duplicates_files"
    description: "Summary of duplicates removed with Picard tool MarkDuplicates (for multiple reads aligned to the same positions) for control"
    type:
      type: array
      items: File
  - id: "#map_control_dedup_bam_files"
    source: "#map_control.output_data_sorted_dedup_bam_files"
    description: "Filtered BAM files (post-processing end point) for control"
    type:
      type: array
      items: File
  - id: "#map_control_dedup_bam_index_files"
    source: "#map_control.output_index_dedup_bam_files"
    description: "Filtered BAM index files for control"
    type:
      type: array
      items: File
  - id: "#map_control_pbc_files"
    source: "#map_control.output_pbc_files"
    description: "PCR Bottleneck Coefficient files (used to flag samples when pbc<0.5) for control"
    type:
      type: array
      items: File
steps:
  - id: "#qc_treatment"
    run: {import: "processing_step1/01-qc-pe.cwl"}
    inputs:
      - { id: "#qc_treatment.input_read1_fastq_files", source: "#input_treatment_fastq_read1_files" }
      - { id: "#qc_treatment.input_read2_fastq_files", source: "#input_treatment_fastq_read2_files" }
      - { id: "#qc_treatment.default_adapters_file", source: "#default_adapters_file" }
      - { id: "#qc_treatment.nthreads", source: "#nthreads_qc" }
    outputs:
      - { id:  "#qc_treatment.output_count_raw_reads_read1" }
      - { id:  "#qc_treatment.output_count_raw_reads_read2" }
      - { id:  "#qc_treatment.output_diff_counts_read1" }
      - { id:  "#qc_treatment.output_diff_counts_read2" }
      - { id:  "#qc_treatment.output_fastqc_report_files_read1" }
      - { id:  "#qc_treatment.output_fastqc_report_files_read2" }
      - { id:  "#qc_treatment.output_fastqc_data_files_read1" }
      - { id:  "#qc_treatment.output_fastqc_data_files_read2" }
      - { id:  "#qc_treatment.output_custom_adapters_read1" }
      - { id:  "#qc_treatment.output_custom_adapters_read2" }
  - id: "#trimm_treatment"
    run: {import: "processing_step1/02-trim-pe.cwl"}
    inputs:
      - {id: "#trimm_treatment.input_read1_fastq_files", source: "#input_treatment_fastq_read1_files"}
      - {id: "#trimm_treatment.input_read2_fastq_files", source: "#input_treatment_fastq_read2_files"}
      - {id: "#trimm_treatment.input_read1_adapters_files", source: "#qc_treatment.output_custom_adapters_read1"}
      - {id: "#trimm_treatment.input_read2_adapters_files", source: "#qc_treatment.output_custom_adapters_read2"}
      - {id: "#trimm_treatment.nthreads", source: "#nthreads_trimm"}
    outputs:
      - { id:  "#trimm_treatment.output_data_fastq_read1_trimmed_files" }
      - { id:  "#trimm_treatment.output_data_fastq_read2_trimmed_files" }
      - { id:  "#trimm_treatment.output_trimmed_read1_fastq_read_count" }
      - { id:  "#trimm_treatment.output_trimmed_read2_fastq_read_count" }
  - id: "#map_treatment"
    run: {import: "processing_step1/03-map-pe.cwl"}
    inputs:
      - {id: "#map_treatment.input_fastq_read1_files", source: "#trimm_treatment.output_data_fastq_read1_trimmed_files"}
      - {id: "#map_treatment.input_fastq_read2_files", source: "#trimm_treatment.output_data_fastq_read2_trimmed_files"}
      - {id: "#map_treatment.genome_ref_first_index_file", source: "#genome_ref_first_index_file"}
      - {id: "#map_treatment.genome_sizes_file", source: "#genome_sizes_file"}
      - {id: "#map_treatment.ENCODE_blacklist_bedfile", source: "#ENCODE_blacklist_bedfile"}
      - {id: "#map_treatment.nthreads", source: "#nthreads_map"}
    outputs:
      - { id:  "#map_treatment.output_data_sorted_dedup_bam_files" }
      - { id:  "#map_treatment.output_index_dedup_bam_files" }
      - { id:  "#map_treatment.output_picard_mark_duplicates_files" }
      - { id:  "#map_treatment.output_pbc_files" }
  - id: "#qc_control"
    run: {import: "processing_step1/01-qc-pe.cwl"}
    inputs:
      - { id: "#qc_control.input_read1_fastq_files", source: "#input_control_fastq_read1_files" }
      - { id: "#qc_control.input_read2_fastq_files", source: "#input_control_fastq_read2_files" }
      - { id: "#qc_control.default_adapters_file", source: "#default_adapters_file" }
      - { id: "#qc_control.nthreads", source: "#nthreads_qc" }
    outputs:
      - { id:  "#qc_control.output_count_raw_reads_read1" }
      - { id:  "#qc_control.output_count_raw_reads_read2" }
      - { id:  "#qc_control.output_diff_counts_read1" }
      - { id:  "#qc_control.output_diff_counts_read2" }
      - { id:  "#qc_control.output_fastqc_report_files_read1" }
      - { id:  "#qc_control.output_fastqc_report_files_read2" }
      - { id:  "#qc_control.output_fastqc_data_files_read1" }
      - { id:  "#qc_control.output_fastqc_data_files_read2" }
      - { id:  "#qc_control.output_custom_adapters_read1" }
      - { id:  "#qc_control.output_custom_adapters_read2" }
  - id: "#trimm_control"
    run: {import: "processing_step1/02-trim-pe.cwl"}
    inputs:
      - {id: "#trimm_control.input_read1_fastq_files", source: "#input_control_fastq_read1_files"}
      - {id: "#trimm_control.input_read2_fastq_files", source: "#input_control_fastq_read2_files"}
      - {id: "#trimm_control.input_read1_adapters_files", source: "#qc_control.output_custom_adapters_read1"}
      - {id: "#trimm_control.input_read2_adapters_files", source: "#qc_control.output_custom_adapters_read2"}
      - {id: "#trimm_control.nthreads", source: "#nthreads_trimm"}
    outputs:
      - { id:  "#trimm_control.output_data_fastq_read1_trimmed_files" }
      - { id:  "#trimm_control.output_data_fastq_read2_trimmed_files" }
      - { id:  "#trimm_control.output_trimmed_read1_fastq_read_count" }
      - { id:  "#trimm_control.output_trimmed_read2_fastq_read_count" }
  - id: "#map_control"
    run: {import: "processing_step1/03-map-pe.cwl"}
    inputs:
      - {id: "#map_control.input_fastq_read1_files", source: "#trimm_control.output_data_fastq_read1_trimmed_files"}
      - {id: "#map_control.input_fastq_read2_files", source: "#trimm_control.output_data_fastq_read2_trimmed_files"}
      - {id: "#map_control.genome_ref_first_index_file", source: "#genome_ref_first_index_file"}
      - {id: "#map_control.genome_sizes_file", source: "#genome_sizes_file"}
      - {id: "#map_control.ENCODE_blacklist_bedfile", source: "#ENCODE_blacklist_bedfile"}
      - {id: "#map_control.nthreads", source: "#nthreads_map"}
    outputs:
      - { id:  "#map_control.output_data_sorted_dedup_bam_files" }
      - { id:  "#map_control.output_index_dedup_bam_files" }
      - { id:  "#map_control.output_picard_mark_duplicates_files" }
      - { id:  "#map_control.output_pbc_files" }