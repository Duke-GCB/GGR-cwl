#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0
doc: 'ChIP-seq 02 trimming - reads: SE'
requirements:
 - class: ScatterFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
inputs:
   input_read1_fastq_files:
     doc: Input fastq files
     type: File[]
   input_adapters_files:
     doc: Input adapters files
     type: File[]
   nthreads:
     default: 1
     doc: Number of threads
     type: int
   quality_score:
     default: -phred33
     type: string
   trimmomatic_java_opts:
     doc: JVM arguments should be a quoted, space separated list
     type: string?
   trimmomatic_jar_path:
     default: /usr/share/java/trimmomatic.jar
     doc: Trimmomatic Java jar file
     type: string
steps:
   extract_basename:
     run: ../utils/basename.cwl
     scatter: file_path
     in:
       file_path:
         source: trimmomatic/output_read1_trimmed_file
         valueFrom: $(self.basename)
       sep:
         valueFrom: '(\.fastq.gz|\.fastq)'
       do_not_escape_sep:
         valueFrom: ${return true}
     out:
     - basename
   count_fastq_reads:
     run: ../utils/count-fastq-reads.cwl
     scatterMethod: dotproduct
     scatter:
     - input_fastq_file
     - input_basename
     in:
       input_basename: extract_basename/basename
       input_fastq_file: trimmomatic/output_read1_trimmed_file
     out:
     - output_read_count
   trimmomatic:
     run: ../trimmomatic/trimmomatic.cwl
     scatterMethod: dotproduct
     scatter:
     - input_read1_fastq_file
     - input_adapters_file
     in:
       phred:
         valueFrom: '33'
       nthreads: nthreads
       minlen:
         valueFrom: ${return 15}
       java_opts: trimmomatic_java_opts
       leading:
         valueFrom: ${return 3}
       slidingwindow:
         valueFrom: 4:20
       illuminaclip:
         valueFrom: 2:30:15
       input_read1_fastq_file: input_read1_fastq_files
       input_adapters_file: input_adapters_files
       trailing:
         valueFrom: ${return 3}
       trimmomatic_jar_path: trimmomatic_jar_path
       end_mode:
         valueFrom: SE
     out:
     - output_read1_trimmed_file
outputs:
   output_data_fastq_trimmed_files:
     doc: Trimmed fastq files
     type: File[]
     outputSource: trimmomatic/output_read1_trimmed_file
   output_trimmed_fastq_read_count:
     doc: Trimmed read counts of fastq files
     type: File[]
     outputSource: count_fastq_reads/output_read_count