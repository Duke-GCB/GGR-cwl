#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/samtools'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: "#input_file"
    type: File
    description: "Aligned file to be sorted with samtools"
    inputBinding:
      position: 1

outputs:
  - id: "#sorted_file"
    type: File
    description: "Sorted aligned file"
    outputBinding:
      glob: $(inputs.input_file.path.split('/').slice(-1)[0] + '.sorted')

baseCommand: ["samtools", "sort"]
stdout: $(inputs.input_file.path.split('/').slice(-1)[0] + '.sorted')