#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Extracts the base name of a file"

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/workflow-utils'

inputs:
  - id: "#file_path"
    type: string
    inputBinding:
      position: 1
outputs:
  - id: "#output_path"
    type: string
    outputBinding:
      outputEval: $(inputs.file_path.replace(/\.[^/.]+$/, ""))

baseCommand: echo
