 class: CommandLineTool
 cwlVersion: v1.0
 doc: Concat file1 and file2 into output_file.
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    input_file1:
      type: File
      inputBinding:
        position: 1
    input_file2:
      type: File
      inputBinding:
        position: 2
 outputs:
    output_file:
      type: File
      outputBinding:
        glob: $(inputs.input_file1.path.replace(/.*\/|\.[^.]*$/g, "") + "_" + inputs.input_file2.path.replace(/.*\/|\.[^.]*$/g, "") + ".joined")
 baseCommand: cat
 stdout: $(inputs.input_file1.path.replace(/.*\/|\.[^.]*$/g, "") + "_" + inputs.input_file2.path.replace(/.*\/|\.[^.]*$/g, "") + ".joined")
