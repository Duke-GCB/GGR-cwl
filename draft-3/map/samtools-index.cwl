#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/samtools'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: "#input_file"
    type: File
    description: "Aligned file to be sorted with samtools"
    inputBinding:
      position: 1

outputs:
  - id: "#index_file"
    type: File
    description: "Index aligned file"
    outputBinding:
      glob: $(inputs.input_file.path.split('/').slice(-1)[0] + '.bai')

baseCommand: ["samtools", "index"]
arguments:
  - valueFrom: $(inputs.input_file.path.split('/').slice(-1)[0] + '.bai')
    position: 2
