#!/usr/bin/env cwl-runner

# To generate the output file name, we use some inline javascript
# Unfortunately this is duplicated for stdout and for output globbing
# Would be nice to run this expression in one place and use it for both
# but I couldn't get that working as a string input with valueFrom in a binding
# like I did in draft 2 with py-expr-engine

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
