#!/usr/bin/env cwl-runner

cwlVersion: 'cwl:draft-3.dev3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/bedgraphtobigwig'

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

outputs:
  - id: '#output_bigwig'
    type: File
    outputBinding:
      glob: $(inputs.bed_graph.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.bw')

baseCommand: bedGraphToBigWig
arguments:
  - valueFrom: $(inputs.bed_graph.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.bw')
    position: 3

description: "Tool:   bedGraphToBigWig v 4 - Convert a bedGraph file to bigWig format."
