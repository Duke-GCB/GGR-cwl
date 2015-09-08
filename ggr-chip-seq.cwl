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
  - id: "#bowtie_index_dir"
    type: File
    description: "Directory containing bowtie index files"
  - id: "#bowtie_index_prefix"
    type: string
    description: "Index filename prefix (minus trailing .X.bt2)."

outputs:
  - id: "#output_qc_report_file"
    type: File
    description: "Output FastQC Report file"
    source: "#fastqc.output_qc_report_file"
  - id: "#output_trimmed_file"
    type: File
    description: "Output Trimmed file"
    source: "#trimmomatic.output_trimmed_file"
  - id: "#output_aligned_file"
    type: File
    description: "Output Aligned file"
    source: "#bowtie2.output_aligned_file"
  - id: "#output_alignment_metrics_file"
    type: File
    description: "Output Alignment Metrics file"
    source: "#bowtie2.output_alignment_metrics_file"

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
    - { id: "#trimmomatic.output_trimmed_file" }
  - id: "#bowtie2"
    run: { import: bowtie2/bowtie2.cwl }
    inputs:
    - { id: "#bowtie2.input_fastq_file", source: "#trimmomatic.output_trimmed_file" }
    - { id: "#bowtie2.index_dir", source: "#bowtie_index_dir" }
    - { id: "#bowtie2.index_prefix", source: "#bowtie_index_prefix" }
    outputs:
    - { id: "#bowtie2.output_aligned_file" }
    - { id: "#bowtie2.output_alignment_metrics_file" }
