#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/trimmomatic'

inputs:
  - id: "#threads"
    type: int
    default: 1
    inputBinding:
      position: 1
      prefix: -threads
  - id: "#quality_score"
    type: string
    default: "-phred33" # or "-phred64"
    inputBinding:
      position: 2
  - id: "#input_read1_fastq_file"
    type: File
    inputBinding:
      position: 3
  - id: "#input_read2_fastq_file"
    type: File
    inputBinding:
      position: 4
  - id: "#input_adapters_file"
    type: File

outputs:
  - id: "#output_read1_trimmed_paired_file"
    type: File
    outputBinding:
      glob: $(inputs.input_read1_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.paired.trimmed.fastq')
  - id: "#output_read1_trimmed_unpaired_file"
    type: File
    outputBinding:
      glob: $(inputs.input_read1_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.unpaired.trimmed.fastq')
  - id: "#output_read2_trimmed_paired_file"
    type: File
    outputBinding:
      glob: $(inputs.input_read2_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.paired.trimmed.fastq')
  - id: "#output_read2_trimmed_unpaired_file"
    type: File
    outputBinding:
      glob: $(inputs.input_read2_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.unpaired.trimmed.fastq')

baseCommand: TrimmomaticPE
arguments:
  - valueFrom: $(inputs.input_read1_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.paired.trimmed.fastq')
    position: 5
  - valueFrom: $(inputs.input_read1_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.unpaired.trimmed.fastq')
    position: 6
  - valueFrom: $(inputs.input_read2_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.paired.trimmed.fastq')
    position: 7
  - valueFrom: $(inputs.input_read2_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.unpaired.trimmed.fastq')
    position: 8
  - valueFrom: $("ILLUMINACLIP:" + inputs.input_adapters_file.path + ":2:30:15")
    position: 9
  - valueFrom: $("LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:10")
    position: 10
