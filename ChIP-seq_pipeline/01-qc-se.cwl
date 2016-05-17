#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "ChIP-seq 01 QC - reads: SE"
requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
inputs:
  - id: "#input_fastq_files"
    type:
      type: array
      items: File
    description: "Input fastq files"
  - id: "#default_adapters_file"
    type: File
    description: "Adapters file"
  - id: "#nthreads"
    description: "Number of threads."
    type: int
outputs:
  - id: "#output_raw_read_counts"
    source: "#count_raw_reads.output_read_count"
    description: "Raw read counts of fastq files"
    type:
      type: array
      items: File
  - id: "#output_fastqc_read_counts"
    source: "#count_fastqc_reads.output_fastqc_read_count"
    description: "Read counts of fastq files from FastQC"
    type:
      type: array
      items: File
  - id: "#output_fastqc_report_files"
    source: "#fastqc.output_qc_report_file"
    description: "FastQC reports in zip format"
    type:
      type: array
      items: File
  - id: "#output_fastqc_data_files"
    source: "#extract_fastqc_data.output_fastqc_data_file"
    type:
      type: array
      items: File
  - id: "#output_custom_adapters"
    source: "#overrepresented_sequence_extract.output_custom_adapters"
    type:
      type: array
      items: File
steps:
  - id: "#extract_basename"
    run: {$import: "../utils/extract-basename.cwl" }
    scatter: "#extract_basename.input_file"
    inputs:
      - id: "#extract_basename.input_file"
        source: "#input_fastq_files"
    outputs:
      - id: "#extract_basename.output_basename"
  - id: "#count_raw_reads"
    run: {$import: "../utils/count-fastq-reads.cwl" }
    scatter:
      - "#count_raw_reads.input_fastq_file"
      - "#count_raw_reads.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#count_raw_reads.input_fastq_file"
        source: "#input_fastq_files"
      - id: "#count_raw_reads.input_basename"
        source: "#extract_basename.output_basename"
    outputs:
      - id: "#count_raw_reads.output_read_count"
  - id: "#fastqc"
    run: {$import: "../qc/fastqc.cwl" }
    scatter: "#fastqc.input_fastq_file"
    inputs:
      - id: "#fastqc.input_fastq_file"
        source: "#input_fastq_files"
      - id: "#fastqc.threads"
        source: "#nthreads"
    outputs:
      - id: "#fastqc.output_qc_report_file"
  - id: "#extract_fastqc_data"
    run: {$import: "../qc/extract_fastqc_data.cwl" }
    scatter:
      - "#extract_fastqc_data.input_qc_report_file"
      - "#extract_fastqc_data.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#extract_fastqc_data.input_qc_report_file"
        source: "#fastqc.output_qc_report_file"
      - id: "#extract_fastqc_data.input_basename"
        source: "#extract_basename.output_basename"
    outputs:
      - id: "#extract_fastqc_data.output_fastqc_data_file"
  - id: "#overrepresented_sequence_extract"
    run: {$import: "../qc/overrepresented_sequence_extract.cwl" }
    scatter:
      - "#overrepresented_sequence_extract.input_fastqc_data"
      - "#overrepresented_sequence_extract.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#overrepresented_sequence_extract.input_fastqc_data"
        source: "#extract_fastqc_data.output_fastqc_data_file"
      - id: "#overrepresented_sequence_extract.default_adapters_file"
        source: "#default_adapters_file"
      - id: "#overrepresented_sequence_extract.input_basename"
        source: "#extract_basename.output_basename"
    outputs:
      - id: "#overrepresented_sequence_extract.output_custom_adapters"
  - id: "#count_fastqc_reads"
    run: {$import: "../qc/count-fastqc-reads.cwl" }
    scatter:
      - "#count_fastqc_reads.input_fastqc_data"
      - "#count_fastqc_reads.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#count_fastqc_reads.input_fastqc_data"
        source: "#extract_fastqc_data.output_fastqc_data_file"
      - id: "#count_fastqc_reads.input_basename"
        source: "#extract_basename.output_basename"
    outputs:
      - id: "#count_fastqc_reads.output_fastqc_read_count"
  - id: "#compare_read_counts"
    run: {$import: "../qc/diff.cwl" }
    scatter:
      - "#compare_read_counts.file1"
      - "#compare_read_counts.file2"
    scatterMethod: dotproduct
    inputs:
      - id: "#compare_read_counts.file1"
        source: "#count_raw_reads.output_read_count"
      - id: "#compare_read_counts.file2"
        source: "#count_fastqc_reads.output_fastqc_read_count"
    outputs:
      - id: "#compare_read_counts.result"