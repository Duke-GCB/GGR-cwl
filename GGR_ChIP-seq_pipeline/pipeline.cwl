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

outputs:
  - id: "#output_raw_read_counts"
    source: "#qc.output_raw_read_counts"
    description: "Raw read counts of fastq files"
    type:
      type: array
      items: File
  - id: "#output_fastqc_read_counts"
    source: "#qc.output_fastqc_read_counts"
    description: "Read counts of fastq files from FastQC"
    type:
      type: array
      items: File
  - id: "#output_fastqc_report_files"
    source: "#qc.output_fastqc_report_files"
    description: "FastQC reports in zip format"
    type:
      type: array
      items: File
  - id: "#output_fastqc_data_files"
    source: "#qc.output_fastqc_data_files"
    type:
      type: array
      items: File
  - id: "#output_custom_adapters"
    source: "#qc.output_custom_adapters"
    type:
      type: array
      items: File

steps:
  - id: "#qc"
    run: {import: "./01-qc-se.cwl"}
    # scatter: "#qc.input_fastq_files"
    inputs:
      - id: "#qc.input_fastq_files"
        source: "#input_fastq_files"
      - id: "#qc.default_adapters_file"
        source: "#default_adapters_file"
    outputs:
      - { id:  "#qc.output_raw_read_counts" }
      - { id:  "#qc.output_fastqc_read_counts" }
      - { id:  "#qc.output_fastqc_report_files" }
      - { id:  "#qc.output_fastqc_data_files" }
      - { id:  "#qc.output_custom_adapters" }