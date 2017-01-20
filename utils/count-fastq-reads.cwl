#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Counts reads in a fastq file"

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/workflow-utils'

inputs:
  - id: "#input_fastq_file"
    type: File
    inputBinding:
      position: 1
  - id: "#input_basename"
    type: string
outputs:
  - id: "#output_read_count"
    type: File
    outputBinding:
      glob: $(inputs.input_basename + '.read_count.txt')

baseCommand: count-fastq-reads.sh
stdout: $(inputs.input_basename + '.read_count.txt')
