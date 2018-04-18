 class: CommandLineTool
 cwlVersion: v1.0
 doc: Extracts the base name of a file
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
 outputs:
    output_basename:
      type: string
      outputBinding:
        outputEval: $(inputs.input_file.path.substr(inputs.input_file.path.lastIndexOf('/') + 1, inputs.input_file.path.lastIndexOf('.') - (inputs.input_file.path.lastIndexOf('/') + 1)))
 baseCommand: echo
