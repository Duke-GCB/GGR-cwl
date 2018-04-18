#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0
doc: 'RNA-seq 02 trimming - reads: SE'
requirements:
 - class: ScatterFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
inputs:
   input_fastq_read1_files:
     doc: Input read 1 fastq files
     type: File[]
   input_read1_adapters_files:
     doc: Input read 1 adapters files
     type: File[]
   nthreads:
     default: 1
     doc: Number of threads
     type: int
   trimmomatic_java_opts:
     doc: JVM arguments should be a quoted, space separated list
     type: string?
   quality_score:
     default: -phred33
     type: string
   trimmomatic_jar_path:
     default: /usr/share/java/trimmomatic.jar
     doc: Trimmomatic Java jar file
     type: string
outputs:
   output_data_fastq_read1_trimmed_files:
     doc: Trimmed fastq files for paired read 1
     type: File[]
     outputSource: trimmomatic/output_read1_trimmed_file
   output_trimmed_read1_fastq_read_count:
     doc: Trimmed read counts of paired read 1 fastq files
     type: File[]
     outputSource: count_fastq_reads_read1/output_read_count
steps:
   trimmomatic:
     run: ../trimmomatic/trimmomatic.cwl
     scatterMethod: dotproduct
     scatter:
     - input_read1_fastq_file
     - input_adapters_file
     in:
       input_read1_fastq_file: input_fastq_read1_files
       phred:
         valueFrom: '33'
       nthreads: nthreads
       minlen:
         valueFrom: ${return 15}
       input_adapters_file: input_read1_adapters_files
       leading:
         valueFrom: ${return 3}
       slidingwindow:
         valueFrom: 4:20
       illuminaclip:
         valueFrom: 2:30:15
       end_mode:
         valueFrom: SE
       java_opts: trimmomatic_java_opts
       trailing:
         valueFrom: ${return 3}
       trimmomatic_jar_path: trimmomatic_jar_path
     out:
     - output_read1_trimmed_file
   extract_basename_read1:
     run: ../utils/extract-basename.cwl
     scatter: input_file
     in:
       input_file: trimmomatic/output_read1_trimmed_file
     out:
     - output_basename
   count_fastq_reads_read1:
     run: ../utils/count-fastq-reads.cwl
     scatterMethod: dotproduct
     scatter:
     - input_fastq_file
     - input_basename
     in:
       input_basename: extract_basename_read1/output_basename
       input_fastq_file: trimmomatic/output_read1_trimmed_file
     out:
     - output_read_count