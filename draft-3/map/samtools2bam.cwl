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
  - id: "#nthreads"
    type: int
    default: 1
    description: "Number of threads used"
    inputBinding:
      position: 1
      prefix: "-@"

outputs:
  - id: "#bam_file"
    type: File
    description: "Aligned file in BAM format"
    outputBinding:
      glob: $(inputs.input_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + '.bam')

baseCommand: ["samtools", "view", "-b"]
stdout: $(inputs.input_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + '.bam')
