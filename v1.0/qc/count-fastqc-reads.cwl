 class: CommandLineTool
 cwlVersion: v1.0
 doc: Extracts read count from fastqc_data.txt
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    input_fastqc_data:
      type: File
      inputBinding:
        position: 1
    input_basename:
      type: string
 outputs:
    output_fastqc_read_count:
      type: File
      outputBinding:
        glob: $(inputs.input_basename + '.fastqc-read_count.txt')
 baseCommand: count-fastqc_data-reads.sh
 stdout: $(inputs.input_basename + '.fastqc-read_count.txt')
