#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Filter out reads from a BED file that are too concentrated within a base-pair window."

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/windowtrimmer'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: "#input_file"
    type: File
    description: "BED file containing the reads to be filter."
    inputBinding:
      position: 1
      prefix: '-i'
  - id: "#window_size"
    type:
      - 'null'
      - int
    description: |
      WINDOWSIZE
              Window size threshold for trimming reads that have the same mapping start position.
    inputBinding:
      position: 1
      prefix: '-w'
  - id: "#cutoff"
    type:
      - 'null'
      - float
    description: |
      CUTOFF
              threshold for concentration at a single base
              within a window to cutoff
    inputBinding:
      position: 1
      prefix: '-c'

outputs:
  - id: "#filtered_file"
    type: File
    description: "Filtered BED file"
    outputBinding:
      glob: $(inputs.input_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + '.filtered.bed')

baseCommand: windowTrimmer.py
stdout: $(inputs.input_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + '.filtered.bed')
