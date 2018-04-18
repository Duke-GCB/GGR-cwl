 class: CommandLineTool
 cwlVersion: v1.0
 doc: Extracts best fragment length from SPP output text file
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    input_spp_txt_file:
      type: File
      inputBinding:
        position: 1
 outputs:
    output_best_frag_length:
      type: float
      outputBinding:
        glob: best_frag_length
        loadContents: true
        outputEval: $(Number(self[0].contents.replace('\n', '')))
 baseCommand: extract-best-frag-length.sh
 stdout: best_frag_length
