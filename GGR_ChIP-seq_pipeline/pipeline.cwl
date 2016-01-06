#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR_ChIP-seq"
requirements:
  - class: ScatterFeatureRequirement

inputs:
  - id: "#input_fastq_files"
    type:
      type: array
      items: File
    description: "Input fastq files"

outputs:
  - id: "#output_fastqc_report_files"
    source: "#fastqc.output_qc_report_file"
    type:
      type: array
      items: File
    description: "fastqc reports"

steps:
  - id: "#fastqc"
    run: {import: "../fastqc/fastqc.cwl" }
    scatter: "#fastqc.input_fastq_file"
    inputs:
      - id: "#fastqc.input_fastq_file"
        source: "#input_fastq_files"
    outputs:
      - id: "#fastqc.output_qc_report_file"
