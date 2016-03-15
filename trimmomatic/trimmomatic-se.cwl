#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/trimmomatic'

inputs:
  - id: "#nthreads"
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
  - id: "#input_fastq_file"
    type: File
    inputBinding:
      position: 3
  - id: "#input_adapters_file"
    type: File


outputs:
  - id: "#output_trimmed_file"
    type: File
    outputBinding:
      glob: $(inputs.input_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.trimmed.fastq')

baseCommand: TrimmomaticSE
arguments:
  - valueFrom: $(inputs.input_fastq_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.trimmed.fastq')
    position: 4
  - valueFrom: $("ILLUMINACLIP:" + inputs.input_adapters_file.path + ":2:30:15")
    position: 5
  - valueFrom: $("LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:10")
    position: 6
