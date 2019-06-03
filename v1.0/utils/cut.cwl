 class: CommandLineTool
 cwlVersion: v1.0
 doc: Cut columns from input file.
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    input_file:
      type: File
      inputBinding:
        position: 1
    columns:
      type: string
      inputBinding:
        position: 2
        prefix: -f
    suffix:
      type: string
      default: .cut.txt
 outputs:
    output_file:
      type: File
      outputBinding:
        glob: $(inputs.input_file.nameroot + inputs.suffix)
 baseCommand: cut
 stdout: $(inputs.input_file.nameroot + inputs.suffix)
