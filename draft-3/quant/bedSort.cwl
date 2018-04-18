#!/usr/bin/env cwl-runner

cwlVersion: 'cwl:draft-3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerPull: 'dleehr/docker-hubutils'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: "#bed_file"
    type: File
    description: "Bed or bedGraph file to be sorted"
    inputBinding:
      position: 1

outputs:
  - id: '#bed_file_sorted'
    type: File
    outputBinding:
      glob: $(inputs.bed_file.path.replace(/^.*[\\\/]/, '') + "_sorted")

baseCommand: bedSort
arguments:
  - valueFrom: $(inputs.bed_file.path.replace(/^.*[\\\/]/, '') + "_sorted")
    position: 2

description: |
  bedSort - Sort a .bed file by chrom,chromStart
  usage:
     bedSort in.bed out.bed
  in.bed and out.bed may be the same.
