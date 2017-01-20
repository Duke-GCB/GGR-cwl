#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Extracts read count from fastqc_data.txt"

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/workflow-utils'

inputs:
  - id: "#input_fastqc_data"
    type: File
    inputBinding:
      position: 1
  - id: "#input_basename"
    type: string
outputs:
  - id: "#output_fastqc_read_count"
    type: File
    outputBinding:
      glob: $(inputs.input_basename + '.fastqc-read_count.txt')

baseCommand: count-fastqc_data-reads.sh
stdout: $(inputs.input_basename + '.fastqc-read_count.txt')
