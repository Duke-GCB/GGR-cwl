 class: CommandLineTool
 cwlVersion: v1.0
 doc: Compute PCR Bottleneck Coeficient from BedGraph file.
 inputs:
    bedgraph_file:
      type: File
      inputBinding:
        position: 1
    output_filename:
      type: string
 outputs:
    pbc:
      type: File
      outputBinding:
        glob: $(inputs.output_filename + '.PBC.txt')
 baseCommand:
  - awk
  - $4==1 {N1 += $3 - $2}; $4>=1 {Nd += $3 - $2} END {print N1/Nd}
 stdout: $(inputs.output_filename + '.PBC.txt')
