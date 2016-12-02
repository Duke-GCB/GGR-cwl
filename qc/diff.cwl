#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Compares 2 files"

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/workflow-utils'

inputs:
  - id: "#file1"
    type: File
    inputBinding:
      position: 1
  - id: "#file2"
    type: File
    inputBinding:
      position: 2
  - id: "#brief"
    type: boolean
    default: true
    inputBinding:
      prefix: "--brief"
      position: 3

outputs:
  - id: "#result"
    type: File
    outputBinding:
      glob: stdout.txt

baseCommand: diff
stdout: stdout.txt
