#!/usr/bin/env cwl-runner
class: Workflow
description: "GGR_ChIP-seq pipeline - reads: PE, region: broad, samples: treatment."
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  - id: "#input_fastq_read1_files"
    type:
      type: array
      items: File
    description: "Input fastq paired-end read 1 files"
  - id: "#input_fastq_read2_files"
    type:
      type: array
      items: File
    description: "Input fastq paired-end read 2 files"
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
   - id: "#qc_count_raw_reads_read1"
    source: "#qc.output_count_raw_reads_read1"
    description: "Raw read counts of fastq files for read 1 after QC"
    type:
      type: array
      items: File
 - id: "#qc_count_raw_reads_read2"
    source: "#qc.output_count_raw_reads_read2"
    description: "Raw read counts of fastq files for read 2 after QC"
    type:
      type: array
      items: File
  - id: "#qc_diff_counts_read1"
    source: "#qc.output_diff_counts_read1"
    description: "Diff file between number of raw reads and number of reads counted by FASTQC, read 1"
    type:
      type: array
      items: File
  - id: "#qc_diff_counts_read2"
    source: "#qc.output_diff_counts_read2"
    description: "Diff file between number of raw reads and number of reads counted by FASTQC, read 2"
    type:
      type: array
      items: File
  - id: "#trimm_raw_counts_read1"
    source: "#trimm.output_trimmed_read1_fastq_read_count"
    description: "Raw read counts for R1 of fastq files after TRIMM"
    type:
      type: array
      items: File
  - id: "#trimm_raw_counts_read2"
    source: "#trimm.output_trimmed_read2_fastq_read_count"
    description: "Raw read counts for R2 of fastq files after TRIMM"
    type:
      type: array
      items: File
  - id: "#trimm_fastq_files_read1"
    source: "#trimm.output_data_fastq_read1_trimmed_files"
    description: "FASTQ files after trimming step"
    type:
      type: array
      items: File
  - id: "#trimm_fastq_files_read2"
    source: "#trimm.output_data_fastq_read2_trimmed_files"
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
  - id: "#quant_coverage_bigwig_files"
    source: "#quant.coverage_bigwig_files"
    description: "Sequence coverage in BigWig format"
    type:
      type: array
      items: File
  - id: "#quant_coverage_normalized_bigwig_files"
    source: "#quant.coverage_normalized_bigwig_files"
    description: "Sequence coverage in BigWig format"
    type:
      type: array
      items: File
steps:
  - id: "#qc"
    run: {import: "processing_step1/01-qc-pe.cwl"}
    inputs:
      - { id: "#qc.input_read1_fastq_files", source: "#input_fastq_read1_files" }
      - { id: "#qc.input_read2_fastq_files", source: "#input_fastq_read2_files" }
      - { id: "#qc.default_adapters_file", source: "#default_adapters_file" }
      - { id: "#qc.nthreads", source: "#nthreads_qc" }
    outputs:
      - { id:  "#qc.output_count_raw_reads_read1" }
      - { id:  "#qc.output_count_raw_reads_read2" }
      - { id:  "#qc.output_diff_counts_read1" }
      - { id:  "#qc.output_diff_counts_read2" }
      - { id:  "#qc.output_fastqc_report_files_read1" }
      - { id:  "#qc.output_fastqc_report_files_read2" }
      - { id:  "#qc.output_fastqc_data_files_read1" }
      - { id:  "#qc.output_fastqc_data_files_read2" }
      - { id:  "#qc.output_custom_adapters_read1" }
      - { id:  "#qc.output_custom_adapters_read2" }
  - id: "#trimm"
    run: {import: "processing_step1/02-trim-pe.cwl"}
    inputs:
      - {id: "#trimm.input_read1_fastq_files", source: "#input_fastq_read1_files"}
      - {id: "#trimm.input_read2_fastq_files", source: "#input_fastq_read2_files"}
      - {id: "#trimm.input_read1_adapters_files", source: "#qc.output_custom_adapters_read1"}
      - {id: "#trimm.input_read2_adapters_files", source: "#qc.output_custom_adapters_read2"}
      - {id: "#trimm.nthreads", source: "#nthreads_trimm"}
    outputs:
      - { id:  "#trimm.output_data_fastq_read1_trimmed_files" }
      - { id:  "#trimm.output_data_fastq_read2_trimmed_files" }
      - { id:  "#trimm.output_trimmed_read1_fastq_read_count" }
      - { id:  "#trimm.output_trimmed_read2_fastq_read_count" }
  - id: "#map"
    run: {import: "processing_step1/03-map-pe.cwl"}
    inputs:
      - {id: "#map.input_fastq_read1_files", source: "#trimm.output_data_fastq_read1_trimmed_files"}
      - {id: "#map.input_fastq_read2_files", source: "#trimm.output_data_fastq_read2_trimmed_files"}
      - {id: "#map.genome_ref_first_index_file", source: "#genome_ref_first_index_file"}
      - {id: "#map.genome_sizes_file", source: "#genome_sizes_file"}
      - {id: "#map.ENCODE_blacklist_bedfile", source: "#ENCODE_blacklist_bedfile"}
      - {id: "#map.nthreads", source: "#nthreads_map"}
    outputs:
      - { id:  "#map.output_data_sorted_dedup_bam_files" }
      - { id:  "#map.output_index_dedup_bam_files" }
      - { id:  "#map.output_picard_mark_duplicates_files" }
      - { id:  "#map.output_pbc_files" }