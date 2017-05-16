#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Un-pack a BEDPE concatenating both mates so that they are treated independently"

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/workflow-utils'

inputs:
  - id: "#bedpe"
    type: File
    inputBinding:
      position: 1
outputs:
  - id: "#bed"
    type: File
    outputBinding:
      glob: $(inputs.bedpe.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '').replace(/([_\.]?sorted)*$/, '.unpaired.bed'))

baseCommand: bedpe-to-bed.sh
stdout: $(inputs.bedpe.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '').replace(/([_\.]?sorted)*$/, '.unpaired.bed'))
