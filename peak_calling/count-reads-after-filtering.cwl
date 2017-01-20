#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Count number of dedup-ed reads used in peak calling"

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/workflow-utils'

inputs:
  - id: "#peak_xls_file"
    type: File
    inputBinding:
      position: 1
outputs:
  - id: "#read_count_file"
    type: File
    outputBinding:
      glob: $(inputs.peak_xls_file.path.replace(/^.*[\\\/]/, '').replace(/\_peaks\.xls$/, '_read_count.txt'))

baseCommand: count-filtered-reads-macs2.sh
stdout: $(inputs.peak_xls_file.path.replace(/^.*[\\\/]/, '').replace(/\_peaks\.xls$/, '_read_count.txt'))
