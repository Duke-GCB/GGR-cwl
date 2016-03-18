#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Counts lines in a file and returns a suffixed file with that number"

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/workflow-utils'

inputs:
  - id: "#input_file"
    type: File
    inputBinding:
      position: 2
  - id: "#output_suffix"
    type: string

outputs:
  - id: "#output_counts"
    type: File
    outputBinding:
      glob: $(inputs.input_file.path.replace(/^.*[\\\/]/, '') + inputs.output_suffix)

baseCommand: ['wc', '-l']
arguments:
  - valueFrom: " < "
    shellQuote: False
    position: 2
stdout: $(inputs.input_file.path.replace(/^.*[\\\/]/, '') + inputs.output_suffix)