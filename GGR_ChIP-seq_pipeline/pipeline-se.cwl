#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR_ChIP-seq - Main"
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: "#input_fastq_files"
    type: 
      type: array
      items: File
    description: "Input fastq files"
  - id: "#default_adapters_file"
    type: File
    description: "Adapters file"
  - id: "#genome_ref_first_index_file"
    type: File
    description: "First index file of Bowtie reference genome with extension 1.ebwt. (Note: the rest of the index files MUST be in the same folder)"
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
    description: "Summary of duplicates removed with Picard tool MarkDuplicates"
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
    run: {import: "processing_step1/01-qc-se.cwl"}
    inputs:
      - {id: "#qc.input_fastq_files", source: "#input_fastq_files"}
      - {id: "#qc.default_adapters_file", source: "#default_adapters_file"}
      - {id: "#qc.nthreads", source: "#nthreads_qc"}
    outputs:
      - { id:  "#qc.output_raw_read_counts" }
      - { id:  "#qc.output_fastqc_read_counts" }
      - { id:  "#qc.output_fastqc_report_files" }
      - { id:  "#qc.output_fastqc_data_files" }
      - { id:  "#qc.output_custom_adapters" }
  - id: "#trimm"
    run: {import: "processing_step1/02-trim-se.cwl"}
    inputs:
      - {id: "#trimm.input_fastq_files", source: "#input_fastq_files"}
      - {id: "#trimm.input_adapters_files", source: "#qc.output_custom_adapters"}
      - {id: "#trimm.nthreads", source: "#nthreads_trimm"}
    outputs:
      - { id:  "#trimm.output_data_fastq_trimmed_files" }
      - { id:  "#trimm.trimmed_fastq_read_count" }
  - id: "#map"
    run: {import: "processing_step1/03-map-se.cwl"}
    inputs:
      - {id: "#map.input_fastq_files", source: "#trimm.output_data_fastq_trimmed_files"}
      - {id: "#map.genome_ref_first_index_file", source: "#genome_ref_first_index_file"}
      - {id: "#map.genome_sizes_file", source: "#genome_sizes_file"}
      - {id: "#map.ENCODE_blacklist_bedfile", source: "#ENCODE_blacklist_bedfile"}
      - {id: "#map.nthreads", source: "#nthreads_map"}
    outputs:
      - { id:  "#map.output_data_sorted_dedup_bam_files" }
      - { id:  "#map.output_index_dedup_bam_files" }
      - { id:  "#map.output_picard_mark_duplicates_files" }
      - { id:  "#map.output_pbc_files" }

