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
    description: "File to be converted to BAM with samtools"
    inputBinding:
      position: 2
  - id: "#S"
    type: boolean
    description: "Input format autodetected"
    default: true
    inputBinding:
      position: 1
      prefix: "-S"
  - id: "#h"
    type: boolean
    description: "Include header in output"
    default: true
    inputBinding:
      position: 1
      prefix: "-h"

outputs:
  - id: "#sam_file"
    type: File
    description: "Aligned file in BAM format"
    outputBinding:
      glob: $(inputs.input_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.sam')

baseCommand: ["samtools", "view"]
stdout: $(inputs.input_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.sam')