 class: CommandLineTool
 cwlVersion: v1.0
 doc: |
    bigWigToBedGraph - Convert from bigWig to bedGraph format.
    usage:
       bigWigToBedGraph in.bigWig out.bedGraph
    options:
       -chrom=chr1 - if set restrict output to given chromosome
       -start=N - if set, restrict output to only that over start
       -end=N - if set, restict output to only that under end
       -udcDir=/dir/to/cache - place to put cache for remote bigBed/bigWigs
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dleehr/docker-hubutils
 inputs:
    output_suffix:
      type: string
      default: .bdg
    bigwig_file:
      type: File
      inputBinding:
        position: 1
      doc: Bed file to be clipped
 outputs:
    output_bedgraph:
      type: File
      outputBinding:
        glob: $(inputs.bigwig_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)
 baseCommand: bigWigToBedGraph
 arguments:
  - valueFrom: $(inputs.bigwig_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)
    position: 2
