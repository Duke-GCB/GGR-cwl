#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR: RNA-seq - WIP"

inputs:
  - id: "#input_read1_fastq_file"
    type: File
    description: "Input FASTQ file - Read 1"
  - id: "#input_read2_fastq_file"
    type: File
    description: "Input FASTQ file - Read 2"
  - id: "#input_adapters_file"
    type: File
    description: "Adapters for trimming"
  - id: "#input_star_genome_dir"
    type: File
    description: "Directory containing STAR-formatted Genome"

outputs:
  - id: "#output_read1_qc_report_file"
    type: File
    description: "Output FastQC Report file - Read 1"
    source: "#fastqc1.output_qc_report_file"
  - id: "#output_read2_qc_report_file"
    type: File
    description: "Output FastQC Report file - Read 2"
    source: "#fastqc2.output_qc_report_file"
  - id: "#output_aligned_file"
    type: File
    description: "Output Aligned file"
    source: "#star.output_aligned_file"

steps:
  - id: "#fastqc1"
    run: { import: fastqc/fastqc.cwl }
    inputs:
    - { id: "#fastqc1.input_fastq_file", source: "#input_read1_fastq_file" }
    outputs:
    - { id: "#fastqc1.output_qc_report_file" }
  - id: "#fastqc2"
    run: { import: fastqc/fastqc.cwl }
    inputs:
    - { id: "#fastqc2.input_fastq_file", source: "#input_read2_fastq_file" }
    outputs:
    - { id: "#fastqc2.output_qc_report_file" }
  - id: "#trimmomatic"
    run: { import: trimmomatic/trimmomatic-pe.cwl }
    inputs:
    - { id: "#trimmomatic.input_read1_fastq_file", source: "#input_read1_fastq_file" }
    - { id: "#trimmomatic.input_read2_fastq_file", source: "#input_read2_fastq_file" }
    - { id: "#trimmomatic.input_adapters_file", source: "#input_adapters_file" }
    outputs:
    - { id: "#trimmomatic.output_read1_trimmed_paired_file" }
    - { id: "#trimmomatic.output_read1_trimmed_unpaired_file" }
    - { id: "#trimmomatic.output_read2_trimmed_paired_file" }
    - { id: "#trimmomatic.output_read2_trimmed_unpaired_file" }
  - id: "#star"
    run: { import: star/star.cwl }
    inputs:
    - { id: "#star.input_read1_fastq_file", source: "#trimmomatic.output_read1_trimmed_paired_file" }
    - { id: "#star.input_read2_fastq_file", source: "#trimmomatic.output_read2_trimmed_paired_file" }
    - { id: "#star.input_genome_dir", source: "#input_star_genome_dir" }
    outputs:
    - { id: "#star.output_aligned_file" }
