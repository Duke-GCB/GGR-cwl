#!/usr/bin/env cwl-runner

class: Workflow
description: "GGR_ChIP-seq - Trimm"
requirements:
  - class: ScatterFeatureRequirement

inputs:
  - id: "#input_read1_fastq_files"
    type: 
      type: array
      items: File
    description: "Input read 1 fastq files"
  - id: "#input_read2_fastq_files"
    type:
      type: array
      items: File
    description: "Input read 2 fastq files"
  - id: "#input_read1_adapters_files"
    type:
      type: array
      items: File
    description: "Input read 1 adapters files"
  - id: "#input_read2_adapters_files"
    type:
      type: array
      items: File
    description: "Input read 2 adapters files"
  - id: "#nthreads"
    type: int
    default: 1
    description: "Number of threads"
  - id: "#quality_score"
    type: string
    default: "-phred33"

outputs:
  - id: "#output_data_fastq_read1_trimmed_files"
    source: "#trimmomatic-pe.output_read1_trimmed_paired_file"
    description: "Trimmed fastq files for paired read 1"
    type:
      type: array
      items: File
  - id: "#output_data_fastq_read2_trimmed_files"
    source: "#trimmomatic-pe.output_read2_trimmed_paired_file"
    description: "Trimmed fastq files for paired read 2"
    type:
      type: array
      items: File
  - id: "#output_trimmed_read1_fastq_read_count"
    source: "#count_fastq_reads_read1.output_read_count"
    description: "Trimmed read counts of paired read 1 fastq files"
    type:
      type: array
      items: File
  - id: "#output_trimmed_read2_fastq_read_count"
    source: "#count_fastq_reads_read2.output_read_count"
    description: "Trimmed read counts of paired read 2 fastq files"
    type:
      type: array
      items: File

steps:
  - id: "#concat_adapters"
    run: {import: "../utils/concat-files.cwl"}
    scatter:
      - "#concat_adapters.input_file1"
      - "#concat_adapters.input_file2"
    scatterMethod: dotproduct
    inputs:
      - id: "#concat_adapters.input_file1"
        source: "#input_read1_adapters_files"
      - id: "#concat_adapters.input_file2"
        source: "#input_read2_adapters_files"
    outputs:
      - id: "#concat_adapters.output_file"
  - id: "#trimmomatic-pe"
    run: {import: "../trimmomatic/trimmomatic-pe.cwl"}
    scatter:
      - "#trimmomatic-pe.input_read1_fastq_file"
      - "#trimmomatic-pe.input_read2_fastq_file"
      - "#trimmomatic-pe.input_adapters_file"
    scatterMethod: dotproduct
    inputs:
      - id: "#trimmomatic-pe.input_read1_fastq_file"
        source: "#input_read1_fastq_files"
      - id: "#trimmomatic-pe.input_read2_fastq_file"
        source: "#input_read2_fastq_files"
      - id: "#trimmomatic-pe.input_adapters_file"
        source: "#concat_adapters.output_file"
      - id: "#trimmomatic-pe.nthreads"
        source: "#nthreads"
    outputs:
      - id: "#trimmomatic-pe.output_read1_trimmed_paired_file"
#      - id: "#trimmomatic-pe.output_read1_trimmed_unpaired_file"
      - id: "#trimmomatic-pe.output_read2_trimmed_paired_file"
#      - id: "#trimmomatic-pe.output_read2_trimmed_unpaired_file"
  - id: "#extract_basename_read1"
    run: {import: "../utils/extract-basename.cwl" }
    scatter: "#extract_basename_read1.input_file"
    inputs:
      - id: "#extract_basename_read1.input_file"
        source: "#trimmomatic-pe.output_read1_trimmed_paired_file"
    outputs:
      - id: "#extract_basename_read1.output_basename"
  - id: "#extract_basename_read2"
    run: {import: "../utils/extract-basename.cwl" }
    scatter: "#extract_basename_read2.input_file"
    inputs:
      - id: "#extract_basename_read2.input_file"
        source: "#trimmomatic-pe.output_read2_trimmed_paired_file"
    outputs:
      - id: "#extract_basename_read2.output_basename"
  - id: "#count_fastq_reads_read1"
    run: {import: "../utils/count-fastq-reads.cwl" }
    scatter:
      - "#count_fastq_reads_read1.input_fastq_file"
      - "#count_fastq_reads_read1.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#count_fastq_reads_read1.input_fastq_file"
        source: "#trimmomatic-pe.output_read1_trimmed_paired_file"
      - id: "#count_fastq_reads_read1.input_basename"
        source: "#extract_basename_read1.output_basename"
    outputs:
      - id: "#count_fastq_reads_read1.output_read_count"
  - id: "#count_fastq_reads_read2"
    run: {import: "../utils/count-fastq-reads.cwl" }
    scatter:
      - "#count_fastq_reads_read2.input_fastq_file"
      - "#count_fastq_reads_read2.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#count_fastq_reads_read2.input_fastq_file"
        source: "#trimmomatic-pe.output_read2_trimmed_paired_file"
      - id: "#count_fastq_reads_read2.input_basename"
        source: "#extract_basename_read2.output_basename"
    outputs:
      - id: "#count_fastq_reads_read2.output_read_count"
