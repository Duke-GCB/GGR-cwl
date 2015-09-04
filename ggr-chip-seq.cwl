#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR: ChIP-seq - WIP"

inputs:
  - id: "#input_fastq_file"
    type: File
    description: "Input FASTQ file"

outputs:
  - id: "#output_qc_report_file"
    type: File
    description: "Output FastQC Report file"
    source: "#fastqc.output_qc_report_file"

steps:
  - id: "#fastqc"
    run: { import: fastqc/fastqc.cwl }
    inputs:
    - { id: "#fastqc.input_fastq_file", source: "#input_fastq_file" }
    outputs:
    - { id: "#fastqc.output_qc_report_file" }

# trimmomatic se
# bowtie2
