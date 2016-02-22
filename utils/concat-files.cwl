#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Counts reads in a fastq file"

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
      glob: $(inputs.input_file1.path.replace(/.*\/|\.[^.]*$/g, "") + "-" + inputs.input_file2.path.replace(/.*\/|\.[^.]*$/g, ""))

baseCommand: cat
stdout: $(inputs.input_file1.path.replace(/.*\/|\.[^.]*$/g, "") + "-" + inputs.input_file2.path.replace(/.*\/|\.[^.]*$/g, ""))