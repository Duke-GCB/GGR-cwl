#!/usr/bin/env cwl-runner
class: CommandLineTool
description: "Counts lines in a file and returns a suffixed file with that number"
cwlVersion: cwl:draft-3
requirements:
  - class: InlineJavascriptRequirement
inputs:
    - { id: input_file, type: File}
    - { id: output_suffix, type: string, default: ".count"}
outputs:
    - id: output_counts
      type: File
      outputBinding:
        glob: $(inputs.input_file.path.replace(/^.*[\\\/]/, '') + inputs.output_suffix)
stdin: $(inputs.input_file.path)
stdout: $(inputs.input_file.path.replace(/^.*[\\\/]/, '') + inputs.output_suffix)
baseCommand:
 - wc
 - "-l"