#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Concat file1 and file2 into output_file."

hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/workflow-utils'

inputs:
  - id: "#input_file1"
    type: File
    inputBinding:
      position: 1
  - id: "#input_file2"
    type: File
    inputBinding:
      position: 2
outputs:
  - id: "#output_file"
    type: File
    outputBinding:
      glob: $(inputs.input_file1.path.replace(/.*\/|\.[^.]*$/g, "") + "_" + inputs.input_file2.path.replace(/.*\/|\.[^.]*$/g, "") + ".joined")

baseCommand: cat
stdout: $(inputs.input_file1.path.replace(/.*\/|\.[^.]*$/g, "") + "_" + inputs.input_file2.path.replace(/.*\/|\.[^.]*$/g, "") + ".joined")
