#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Negate minus strand bedGraph values."
hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/workflow-utils'
inputs:
  - id: "#bedgraph_file"
    type: File
    inputBinding:
      position: 1
  - id: "#output_filename"
    type: string

outputs:
  - id: "#negated_minus_bdg"
    type: File
    outputBinding:
      glob: $(inputs.output_filename)

baseCommand:
  - awk
  - 'BEGIN{OFS="\t";FS="\t"} {if ($4 > 0) {print $1,$2,$3,-$4} else {print $0}}'
stdout: $(inputs.output_filename)
