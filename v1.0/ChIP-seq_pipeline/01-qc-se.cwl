#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0
doc: 'ChIP-seq 01 QC - reads: SE'
requirements:
 - class: ScatterFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
inputs:
   input_fastq_files:
     doc: Input fastq files
     type: File[]
   default_adapters_file:
     doc: Adapters file
     type: File
   nthreads:
     doc: Number of threads.
     type: int
steps:
   extract_basename:
     run: ../utils/extract-basename.cwl
     scatter: input_file
     in:
       input_file: input_fastq_files
     out:
     - output_basename
   count_raw_reads:
     run: ../utils/count-fastq-reads.cwl
     scatterMethod: dotproduct
     scatter:
     - input_fastq_file
     - input_basename
     in:
       input_basename: extract_basename/output_basename
       input_fastq_file: input_fastq_files
     out:
     - output_read_count
   fastqc:
     run: ../qc/fastqc.cwl
     scatter: input_fastq_file
     in:
       threads: nthreads
       input_fastq_file: input_fastq_files
     out:
     - output_qc_report_file
   extract_fastqc_data:
     run: ../qc/extract_fastqc_data.cwl
     scatterMethod: dotproduct
     scatter:
     - input_qc_report_file
     - input_basename
     in:
       input_basename: extract_basename/output_basename
       input_qc_report_file: fastqc/output_qc_report_file
     out:
     - output_fastqc_data_file
   overrepresented_sequence_extract:
     run: ../qc/overrepresented_sequence_extract.cwl
     scatterMethod: dotproduct
     scatter:
     - input_fastqc_data
     - input_basename
     in:
       input_fastqc_data: extract_fastqc_data/output_fastqc_data_file
       input_basename: extract_basename/output_basename
       default_adapters_file: default_adapters_file
     out:
     - output_custom_adapters
   count_fastqc_reads:
     run: ../qc/count-fastqc-reads.cwl
     scatterMethod: dotproduct
     scatter:
     - input_fastqc_data
     - input_basename
     in:
       input_fastqc_data: extract_fastqc_data/output_fastqc_data_file
       input_basename: extract_basename/output_basename
     out:
     - output_fastqc_read_count
   compare_read_counts:
     run: ../qc/diff.cwl
     scatterMethod: dotproduct
     scatter:
     - file1
     - file2
     in:
       file2: count_fastqc_reads/output_fastqc_read_count
       file1: count_raw_reads/output_read_count
     out:
     - result
outputs:
   output_custom_adapters:
     outputSource: overrepresented_sequence_extract/output_custom_adapters
     type: File[]
   output_fastqc_data_files:
     doc: FastQC data files for paired read 1
     type: File[]
     outputSource: extract_fastqc_data/output_fastqc_data_file
   output_count_raw_reads:
     outputSource: count_raw_reads/output_read_count
     type: File[]
   output_diff_counts:
     outputSource: compare_read_counts/result
     type: File[]
   output_fastqc_report_files:
     doc: FastQC reports in zip format for paired read 1
     type: File[]
     outputSource: fastqc/output_qc_report_file