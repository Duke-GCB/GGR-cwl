#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR_ChIP-seq - QC"
requirements:
  - class: ScatterFeatureRequirement

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
  - id: "#output_fastqc_report_files"
    source: "#fastqc.output_qc_report_file"
    description: "FastQC reports in zip format"
    type:
      type: array
      items: File
  - id: "#output_custom_adapters"
    source: "#overrepresented_sequence_extract.output_custom_adapters"
    type:
      type: array
      items: File

steps:
  - id: "#fastqc"
    run: {import: "../fastqc/fastqc.cwl" }
    scatter: "#fastqc.input_fastq_file"
    inputs:
      - id: "#fastqc.input_fastq_file"
        source: "#input_fastq_files"
    outputs:
      - id: "#fastqc.output_qc_report_file"
  - id: "#extract_fastqc_data"
    run: {import: "../fastqc/extract_fastqc_data.cwl" }
    scatter: "#extract_fastqc_data.input_qc_report_file"
    inputs:
      - id: "#extract_fastqc_data.input_qc_report_file"
        source: "#fastqc.output_qc_report_file"
    outputs:
      - id: "#extract_fastqc_data.output_fastqc_data_file"
  - id: "#overrepresented_sequence_extract"
    run: {import: "../overrepresented_sequence_extract/overrepresented_sequence_extract.cwl" }
    scatter: "#overrepresented_sequence_extract.input_fastqc_data"
    inputs:
      - id: "#overrepresented_sequence_extract.input_fastqc_data"
        source: "#extract_fastqc_data.output_fastqc_data_file"
      - id: "#overrepresented_sequence_extract.default_adapters_file"
        source: "#default_adapters_file"
    outputs:
      - id: "#overrepresented_sequence_extract.output_custom_adapters"
