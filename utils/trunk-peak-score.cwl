#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Trunk scores in ENCODE bed6+4 files"

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/workflow-utils'

inputs:
  - id: "#peaks"
    type: File
    inputBinding:
      position: 10000
  - id: "#sep"
    type: string
    default: "\\t"
    inputBinding:
      position: 2
      prefix: "-F"
outputs:
  - id: "#trunked_scores_peaks"
    type: File
    outputBinding:
      glob: $(inputs.peaks.path.replace(/^.*[\\\/]/, '').replace(/\.([^/.]+)$/, "\.trunked_scores\.$1"))

baseCommand: awk
arguments:
  - valueFrom: 'BEGIN{OFS=FS}\$5>1000{\$5=1000}{print}'
    position: 3
stdout: $(inputs.peaks.path.replace(/^.*[\\\/]/, '').replace(/\.([^/.]+)$/, "\.trunked_scores\.$1"))