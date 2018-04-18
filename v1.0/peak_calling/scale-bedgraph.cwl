 class: CommandLineTool
 cwlVersion: v1.0
 doc: Scale BedGraph file by scaling factor computed using the number of uniq. mapped reads (library size)
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    output_suffix:
      type: string
      default: .norm.bdg
    bedgraph_file:
      type: File
      inputBinding:
        position: 1
    read_count_file:
      type: File
      inputBinding:
        position: 2
 outputs:
    bedgraph_scaled:
      type: File
      outputBinding:
        glob: $(inputs.bedgraph_file.path.replace(/^.*[\\\/]/, '').replace(/\.bdg$/, '') + inputs.output_suffix)
 baseCommand: scale-bedgraph-by-lib-uniq-reads.sh
 stdout: $(inputs.bedgraph_file.path.replace(/^.*[\\\/]/, '').replace(/\.bdg$/, '') + inputs.output_suffix)
