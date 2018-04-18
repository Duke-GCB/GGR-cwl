 class: CommandLineTool
 cwlVersion: v1.0
 doc: Counts lines in a file and returns a suffixed file with that number
 requirements:
    InlineJavascriptRequirement: {}
 inputs:
    output_suffix: {type: string, default: .count}
    input_file: {type: File}
 outputs:
    output_counts:
      type: File
      outputBinding:
        glob: $(inputs.input_file.path.replace(/^.*[\\\/]/, '') + inputs.output_suffix)
 baseCommand:
  - wc
  - -l
 stdin: $(inputs.input_file.path)
 stdout: $(inputs.input_file.path.replace(/^.*[\\\/]/, '') + inputs.output_suffix)
