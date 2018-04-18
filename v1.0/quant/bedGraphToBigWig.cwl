 class: CommandLineTool
 cwlVersion: v1.0
 doc: 'Tool:   bedGraphToBigWig v 4 - Convert a bedGraph file to bigWig format.'
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dukegcb/bedgraphtobigwig
 inputs:
    output_suffix:
      type: string
      default: .bw
    genome_sizes:
      type: File
      inputBinding:
        position: 2
      doc: "\tgenome_sizes is two column: <chromosome name> <size in bases>.\n"
    bed_graph:
      type: File
      inputBinding:
        position: 1
      doc: "\tbed_graph is a four column file in the format: <chrom> <start> <end> <value>\n"
 outputs:
    output_bigwig:
      type: File
      outputBinding:
        glob: $(inputs.bed_graph.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)
 baseCommand: bedGraphToBigWig
 arguments:
  - valueFrom: $(inputs.bed_graph.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)
    position: 3
