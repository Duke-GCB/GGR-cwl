#!/usr/bin/env cwl-runner
cwlVersion: 'cwl:draft-3'
class: CommandLineTool
description: "Get number of processed reads from STAR log."

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/workflow-utils'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  - { id: star_log,  type: File, inputBinding: {} }

outputs:
    - id: output
      type: File
      outputBinding:
        glob: $(inputs.star_log.path.replace(/^.*[\\\/]/, '') + '.read_count.mapped')

baseCommand: read-count-from-STAR-log.sh
stdout: $(inputs.star_log.path.replace(/^.*[\\\/]/, '') + '.read_count.mapped')
