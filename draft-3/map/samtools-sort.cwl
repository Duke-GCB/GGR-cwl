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
      position: 1000
  - id: "#nthreads"
    type: int
    default: 1
    description: "Number of threads used in sorting"
    inputBinding:
      position: 1
      prefix: "-@"
  - id: "#n"
    type: boolean
    description: "Sort by read name"
    default: false
    inputBinding:
      position: 1
      prefix: "-n"
outputs:
  - id: "#sorted_file"
    type: File
    description: "Sorted aligned file"
    outputBinding:
      glob: $(inputs.input_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + '.sorted.bam')

baseCommand: ["samtools", "sort"]
stdout: $(inputs.input_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + '.sorted.bam')
