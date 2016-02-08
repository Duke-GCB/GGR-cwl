#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Extracts the extension of a file"

inputs:
  - id: "#input_file"
    type: File
    inputBinding:
      position: 1
outputs:
  - id: "#output_extension"
    type: string
    outputBinding:
      outputEval: $(inputs.input_file.path.split('.')[1] || 'UNKNOWN')

baseCommand: echo

