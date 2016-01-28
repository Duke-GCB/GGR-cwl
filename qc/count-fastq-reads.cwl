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
      glob: "read_count.txt"

baseCommand: count-fastq-reads.sh
stdout: read_count.txt
