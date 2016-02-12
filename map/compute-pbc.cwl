#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Compute PCR Bottleneck Coeficient from BedGraph file."

inputs:
  - id: "#bedgraph_file"
    type: File
    inputBinding:
      position: 1

outputs:
  - id: "#pbc"
    type: File
    outputBinding:
      glob: $(inputs.bedgraph_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.PBC.txt')

baseCommand:
  - awk
  - '$4==1 {N1 += $3 - $2}; $4>=1 {Nd += $3 - $2} END {print N1/Nd}'
stdout: $(inputs.bedgraph_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.PBC.txt')