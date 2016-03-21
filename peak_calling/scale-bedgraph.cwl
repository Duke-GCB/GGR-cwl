#!/usr/bin/env cwl-runner

class: CommandLineTool
description: "Scale BedGraph file by scaling factor computed using the number of uniq. mapped reads (library size)"

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/workflow-utils'

inputs:
  - id: "#bedgraph_file"
    type: File
    inputBinding:
      position: 1
  - id: "#read_count_file"
    type: File
    inputBinding:
      position: 2
outputs:
  - id: "#bedgraph_scaled"
    type: File
    outputBinding:
      glob: $(inputs.bedgraph_file.path.replace(/^.*[\\\/]/, '').replace(/\.bdg$/, '.norm.bdg'))

baseCommand: scale-bedgraph-by-lib-uniq-reads.sh
stdout: $(inputs.bedgraph_file.path.replace(/^.*[\\\/]/, '').replace(/\.bdg$/, '.norm.bdg'))