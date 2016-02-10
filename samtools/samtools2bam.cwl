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
#  - id: "#b"
#    type: boolean
#    description: "output BAM"
#    default: true
#    inputBinding:
#      position: 1
#      prefix: "-b"
  - id: "#S"
    type: boolean
    description: "Input format autodetected"
    default: true
    inputBinding:
      position: 1
      prefix: "-S"

outputs:
  - id: "#bam_file"
    type: File
    description: "Aligned file in BAM format"
    outputBinding:
      glob: "*.bam"
      outputEval: $(self[0])

baseCommand: ["samtools", "view", "-b"]
stdout: $(inputs.input_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.bam')