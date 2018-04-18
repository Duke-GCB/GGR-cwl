 class: CommandLineTool
 cwlVersion: v1.0
 doc: Negate minus strand bedGraph values.
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    bedgraph_file:
      type: File
      inputBinding:
        position: 1
    output_filename:
      type: string
 outputs:
    negated_minus_bdg:
      type: File
      outputBinding:
        glob: $(inputs.output_filename)
 baseCommand:
  - awk
  - BEGIN{OFS="\t";FS="\t"} {if ($4 > 0) {print $1,$2,$3,-$4} else {print $0}}
 stdout: $(inputs.output_filename)
