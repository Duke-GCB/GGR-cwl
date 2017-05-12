#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "ATAC-seq 01 QC - reads: PE"
requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
inputs:
  - id: "#input_read1_fastq_files"
    type:
      type: array
      items: File
    description: "Input read1 fastq files"
  - id: "#input_read2_fastq_files"
    type:
      type: array
      items: File
    description: "Input read2 fastq files"
  - id: "#default_adapters_file"
    type: File
    description: "Adapters file"
  - id: "#nthreads"
    description: "Number of threads."
    type: int
outputs:
  - id: "#output_fastqc_report_files_read1"
    source: "#fastqc_read1.output_qc_report_file"
    description: "FastQC reports in zip format for paired read 1"
    type:
      type: array
      items: File
  - id: "#output_fastqc_report_files_read2"
    source: "#fastqc_read2.output_qc_report_file"
    description: "FastQC reports in zip format for paired read 2"
    type:
      type: array
      items: File
  - id: "#output_fastqc_data_files_read1"
    source: "#extract_fastqc_data_read1.output_fastqc_data_file"
    description: "FastQC data files for paired read 1"
    type:
      type: array
      items: File
  - id: "#output_fastqc_data_files_read2"
    source: "#extract_fastqc_data_read2.output_fastqc_data_file"
    description: "FastQC data files for paired read 2"
    type:
      type: array
      items: File
  - id: "#output_custom_adapters_read1"
    source: "#overrepresented_sequence_extract_read1.output_custom_adapters"
    type:
      type: array
      items: File
  - id: "#output_custom_adapters_read2"
    source: "#overrepresented_sequence_extract_read2.output_custom_adapters"
    type:
      type: array
      items: File
  - id: "#output_count_raw_reads_read1"
    source: "#count_raw_reads_read1.output_read_count"
    type:
      type: array
      items: File
  - id: "#output_count_raw_reads_read2"
    source: "#count_raw_reads_read2.output_read_count"
    type:
      type: array
      items: File
  - id: "#output_diff_counts_read1"
    source: "#compare_read_counts_read1.result"
    type:
      type: array
      items: File
  - id: "#output_diff_counts_read2"
    source: "#compare_read_counts_read2.result"
    type:
      type: array
      items: File
steps:
  - id: "#extract_basename_read1"
    run: {$import: "../utils/extract-basename.cwl" }
    scatter: "#extract_basename_read1.input_file"
    inputs:
      - id: "#extract_basename_read1.input_file"
        source: "#input_read1_fastq_files"
    outputs:
      - id: "#extract_basename_read1.output_basename"
  - id: "#extract_basename_read2"
    run: {$import: "../utils/extract-basename.cwl" }
    scatter: "#extract_basename_read2.input_file"
    inputs:
      - id: "#extract_basename_read2.input_file"
        source: "#input_read2_fastq_files"
    outputs:
      - id: "#extract_basename_read2.output_basename"
  - id: "#count_raw_reads_read1"
    run: {$import: "../utils/count-fastq-reads.cwl" }
    scatter:
      - "#count_raw_reads_read1.input_fastq_file"
      - "#count_raw_reads_read1.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#count_raw_reads_read1.input_fastq_file"
        source: "#input_read1_fastq_files"
      - id: "#count_raw_reads_read1.input_basename"
        source: "#extract_basename_read1.output_basename"
    outputs:
      - id: "#count_raw_reads_read1.output_read_count"
  - id: "#count_raw_reads_read2"
    run: {$import: "../utils/count-fastq-reads.cwl" }
    scatter:
      - "#count_raw_reads_read2.input_fastq_file"
      - "#count_raw_reads_read2.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#count_raw_reads_read2.input_fastq_file"
        source: "#input_read2_fastq_files"
      - id: "#count_raw_reads_read2.input_basename"
        source: "#extract_basename_read2.output_basename"
    outputs:
      - id: "#count_raw_reads_read2.output_read_count"
  - id: "#fastqc_read1"
    run: {$import: "../qc/fastqc.cwl" }
    scatter: "#fastqc_read1.input_fastq_file"
    inputs:
      - id: "#fastqc_read1.input_fastq_file"
        source: "#input_read1_fastq_files"
      - id: "#fastqc.threads"
        source: "#nthreads"
    outputs:
      - id: "#fastqc_read1.output_qc_report_file"
  - id: "#fastqc_read2"
    run: {$import: "../qc/fastqc.cwl" }
    scatter: "#fastqc_read2.input_fastq_file"
    inputs:
      - id: "#fastqc_read2.input_fastq_file"
        source: "#input_read2_fastq_files"
      - id: "#fastqc.threads"
        source: "#nthreads"
    outputs:
      - id: "#fastqc_read2.output_qc_report_file"
  - id: "#extract_fastqc_data_read1"
    run: {$import: "../qc/extract_fastqc_data.cwl" }
    scatter:
      - "#extract_fastqc_data_read1.input_qc_report_file"
      - "#extract_fastqc_data_read1.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#extract_fastqc_data_read1.input_qc_report_file"
        source: "#fastqc_read1.output_qc_report_file"
      - id: "#extract_fastqc_data_read1.input_basename"
        source: "#extract_basename_read1.output_basename"
    outputs:
      - id: "#extract_fastqc_data_read1.output_fastqc_data_file"
  - id: "#extract_fastqc_data_read2"
    run: {$import: "../qc/extract_fastqc_data.cwl" }
    scatter:
      - "#extract_fastqc_data_read2.input_qc_report_file"
      - "#extract_fastqc_data_read2.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#extract_fastqc_data_read2.input_qc_report_file"
        source: "#fastqc_read1.output_qc_report_file"
      - id: "#extract_fastqc_data_read2.input_basename"
        source: "#extract_basename_read2.output_basename"
    outputs:
      - id: "#extract_fastqc_data_read2.output_fastqc_data_file"
  - id: "#overrepresented_sequence_extract_read1"
    run: {$import: "../qc/overrepresented_sequence_extract.cwl" }
    scatter:
      - "#overrepresented_sequence_extract_read1.input_fastqc_data"
      - "#overrepresented_sequence_extract_read1.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#overrepresented_sequence_extract_read1.input_fastqc_data"
        source: "#extract_fastqc_data_read1.output_fastqc_data_file"
      - id: "#overrepresented_sequence_extract_read1.default_adapters_file"
        source: "#default_adapters_file"
      - id: "#overrepresented_sequence_extract_read1.input_basename"
        source: "#extract_basename_read1.output_basename"
    outputs:
      - id: "#overrepresented_sequence_extract_read1.output_custom_adapters"
  - id: "#overrepresented_sequence_extract_read2"
    run: {$import: "../qc/overrepresented_sequence_extract.cwl" }
    scatter:
      - "#overrepresented_sequence_extract_read2.input_fastqc_data"
      - "#overrepresented_sequence_extract_read2.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#overrepresented_sequence_extract_read2.input_fastqc_data"
        source: "#extract_fastqc_data_read2.output_fastqc_data_file"
      - id: "#overrepresented_sequence_extract_read2.default_adapters_file"
        source: "#default_adapters_file"
      - id: "#overrepresented_sequence_extract_read2.input_basename"
        source: "#extract_basename_read2.output_basename"
    outputs:
      - id: "#overrepresented_sequence_extract_read2.output_custom_adapters"
  - id: "#count_fastqc_reads_read1"
    run: {$import: "../qc/count-fastqc-reads.cwl" }
    scatter:
      - "#count_fastqc_reads_read1.input_fastqc_data"
      - "#count_fastqc_reads_read1.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#count_fastqc_reads_read1.input_fastqc_data"
        source: "#extract_fastqc_data_read1.output_fastqc_data_file"
      - id: "#count_fastqc_reads_read1.input_basename"
        source: "#extract_basename_read1.output_basename"
    outputs:
      - id: "#count_fastqc_reads_read1.output_fastqc_read_count"
  - id: "#count_fastqc_reads_read2"
    run: {$import: "../qc/count-fastqc-reads.cwl" }
    scatter:
      - "#count_fastqc_reads_read2.input_fastqc_data"
      - "#count_fastqc_reads_read2.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#count_fastqc_reads_read2.input_fastqc_data"
        source: "#extract_fastqc_data_read2.output_fastqc_data_file"
      - id: "#count_fastqc_reads_read2.input_basename"
        source: "#extract_basename_read2.output_basename"
    outputs:
      - id: "#count_fastqc_reads_read2.output_fastqc_read_count"
  - id: "#compare_read_counts_read1"
    run: {$import: "../qc/diff.cwl" }
    scatter:
      - "#compare_read_counts_read1.file1"
      - "#compare_read_counts_read1.file2"
    scatterMethod: dotproduct
    inputs:
      - id: "#compare_read_counts_read1.file1"
        source: "#count_raw_reads_read1.output_read_count"
      - id: "#compare_read_counts_read1.file2"
        source: "#count_fastqc_reads_read1.output_fastqc_read_count"
    outputs:
      - id: "#compare_read_counts_read1.result"
  - id: "#compare_read_counts_read2"
    run: {$import: "../qc/diff.cwl" }
    scatter:
      - "#compare_read_counts_read2.file1"
      - "#compare_read_counts_read2.file2"
    scatterMethod: dotproduct
    inputs:
      - id: "#compare_read_counts_read2.file1"
        source: "#count_raw_reads_read2.output_read_count"
      - id: "#compare_read_counts_read2.file2"
        source: "#count_fastqc_reads_read2.output_fastqc_read_count"
    outputs:
      - id: "#compare_read_counts_read2.result"