#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Counts reads in a fastq file"

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/workflow-utils'

inputs:
  - id: "#input_fastq_file"
    type: File
    inputBinding:
      position: 1
outputs:
  - id: "#output_read_count"
    type: File
    outputBinding:
      glob: $(inputs.input_fastq_file.path.split('/').slice(-1) + '.read_count.txt')

baseCommand: count-fastq-reads.sh
stdout: $(inputs.input_fastq_file.path.split('/').slice(-1) + '.read_count.txt')
