#!/usr/bin/env cwl-runner
cwlVersion: 'cwl:draft-3'
class: CommandLineTool
description: |
  Merge the STAR 1-pass novel splice junction databases ('SJ.out.tab').
  Save only those splice junctions in autosomes and sex chromosomes.
  Filter out splice junctions that are non-canonical, supported by only 10 or fewer reads.

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/star-utils'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  - id: sjdb_files
    type:
      type: array
      items: File
    inputBinding:
      position: 1
      itemSeparator: ","
  - id: sjdb_out_filename
    type: string
    inputBinding:
      position: 2

outputs:
  - id: sjdb_out
    type: File
    outputBinding:
      glob: $(inputs.sjdb_out_filename)

baseCommand: create_SJ.out.tab.Pass1.conservative.sjdb.py
