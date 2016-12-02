#!/usr/bin/env cwl-runner

cwlVersion: 'cwl:draft-3'
class: CommandLineTool

description: "Convert from bigWig to bedGraph format."
hints:
  - class: DockerRequirement
    dockerPull: 'dleehr/docker-hubutils'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: "#bigwig_file"
    type: File
    description: "Bed file to be clipped"
    inputBinding:
      position: 1
  - id: "#output_suffix"
    type: string
    default: ".bdg"

outputs:
  - id: '#output_bedgraph'
    type: File
    outputBinding:
      glob: $(inputs.bigwig_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)

baseCommand: bigWigToBedGraph
arguments:
  - valueFrom: $(inputs.bigwig_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)
    position: 2

description: |
  bigWigToBedGraph - Convert from bigWig to bedGraph format.
  usage:
     bigWigToBedGraph in.bigWig out.bedGraph
  options:
     -chrom=chr1 - if set restrict output to given chromosome
     -start=N - if set, restrict output to only that over start
     -end=N - if set, restict output to only that under end
     -udcDir=/dir/to/cache - place to put cache for remote bigBed/bigWigs
