 class: CommandLineTool
 cwlVersion: v1.0
 doc: Counts reads in a fastq file
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    input_basename:
      type: string
    input_fastq_file:
      type: File
      inputBinding:
        position: 1
 outputs:
    output_read_count:
      type: File
      outputBinding:
        glob: $(inputs.input_basename + '.read_count.txt')
 baseCommand: count-fastq-reads.sh
 stdout: $(inputs.input_basename + '.read_count.txt')
