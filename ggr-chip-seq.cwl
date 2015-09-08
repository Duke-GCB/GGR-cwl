#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR: ChIP-seq - WIP"

inputs:
  - id: "#input_fastq_file"
    type: File
    description: "Input FASTQ file"
  - id: "#input_adapters_file"
    type: File
    description: "Adapters for trimming"

outputs:
  - id: "#output_qc_report_file"
    type: File
    description: "Output FastQC Report file"
    source: "#fastqc.output_qc_report_file"
  - id: "#output_trimmed_file"
    type: File
    description: "Output Trimmed file"
    source: "#trimmomatic.output_trimmed_file"

steps:
  - id: "#fastqc"
    run: { import: fastqc/fastqc.cwl }
    inputs:
    - { id: "#fastqc.input_fastq_file", source: "#input_fastq_file" }
    outputs:
    - { id: "#fastqc.output_qc_report_file" }
  - id: "#trimmomatic"
    run: { import: trimmomatic/trimmomatic-se.cwl }
    inputs:
    - { id: "#trimmomatic.input_fastq_file", source: "#input_fastq_file" }
    - { id: "#trimmomatic.input_adapters_file", source: "#input_adapters_file" }
    outputs:
    - { id: "#trimmomatic.output_trimmed_file", source: "#output_trimmed_file" }

# bowtie2
