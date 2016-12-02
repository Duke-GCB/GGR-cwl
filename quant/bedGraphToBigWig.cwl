#!/usr/bin/env cwl-runner

cwlVersion: 'cwl:draft-3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/bedgraphtobigwig'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: "#bed_graph"
    type: File
    description: "\tbed_graph is a four column file in the format: <chrom> <start> <end> <value>\n"
    inputBinding:
      position: 1
  - id: "#genome_sizes"
    type: File
    description: "\tgenome_sizes is two column: <chromosome name> <size in bases>.\n"
    inputBinding:
      position: 2
  - id: "#output_suffix"
    type: string
    default: ".bw"

outputs:
  - id: '#output_bigwig'
    type: File
    outputBinding:
      glob: $(inputs.bed_graph.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)

baseCommand: bedGraphToBigWig
arguments:
  - valueFrom: $(inputs.bed_graph.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)
    position: 3

description: "Tool:   bedGraphToBigWig v 4 - Convert a bedGraph file to bigWig format."
