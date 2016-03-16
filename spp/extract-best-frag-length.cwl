#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Extracts best fragment length from SPP output text file"

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/workflow-utils'

inputs:
  - id: "#input_spp_txt_file"
    type: File
    inputBinding:
      position: 1
outputs:
  - id: "#output_best_frag_length"
    type: string
    outputBinding:
      glob: "best_frag_length"
      loadContents: True
      outputEval: $(self[0].contents.replace('\n', ''))

baseCommand: extract-best-frag-length.sh
stdout: "best_frag_length"
