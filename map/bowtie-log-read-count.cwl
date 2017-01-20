#!/usr/bin/env cwl-runner
cwlVersion: 'cwl:draft-3'
class: CommandLineTool
description: "Get number of processed reads from Bowtie log."

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/workflow-utils'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  - { id: bowtie_log,  type: File, inputBinding: {} }

outputs:
    - id: output
      type: File
      outputBinding:
        glob: $(inputs.bowtie_log.path.replace(/^.*[\\\/]/, '') + '.read_count.mapped')

baseCommand: read-count-from-bowtie-log.sh
stdout: $(inputs.bowtie_log.path.replace(/^.*[\\\/]/, '') + '.read_count.mapped')
