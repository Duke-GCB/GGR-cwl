#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Compute PCR Bottleneck Coeficient from BedGraph file."

inputs:
  - id: "#bedgraph_file"
    type: File
    inputBinding:
      position: 1
  - id: "#output_filename"
    type: string

outputs:
  - id: "#pbc"
    type: File
    outputBinding:
      glob: $(inputs.output_filename + '.PBC.txt')

baseCommand:
  - awk
  - '$4==1 {N1 += $3 - $2}; $4>=1 {Nd += $3 - $2} END {print N1/Nd}'
stdout: $(inputs.output_filename + '.PBC.txt')