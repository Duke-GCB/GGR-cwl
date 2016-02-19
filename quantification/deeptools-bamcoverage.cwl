#!/usr/bin/env cwl-runner

cwlVersion: 'cwl:draft-3.dev3'
class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/deeptools'

requirements:
  - class: InlineJavascriptRequirement


inputs:
  - id: "#bam"
    type: File
    description: "\t input BAM file\n"
    secondaryFiles: $(self.path + '.bai')
    inputBinding:
      position: 1
      prefix: "--bam"
  - id: "#to_bigwig"
    type: boolean
    description: "\t Generate BigWig output file. \n"
    default: true
    inputBinding:
      position: 1
      prefix: "--outFileFormat=bigwig"
  - id: "#normalize_using_RPKM"
    type:
      - 'null'
      - boolean
    description: "\t Normalize read coundts by RPKM. \n"
    inputBinding:
      position: 1
      prefix: "--normalizeUsingRPKM"
  - id: "#extend_reads"
    type: int
    default: 200
    description: "\t Extend reads by a number of bases. (default: 200) \n"
    inputBinding:
      position: 1
      prefix: "--extendReads"
  - id: "#bin_size"
    type: int
    default: 50
    description: "\t Bin size (default: 50). \n"
    inputBinding:
      position: 1
      prefix: "--binSize"

outputs:
  - id: '#output_bam_coverage'
    type: File
    outputBinding:
      glob: $(inputs.bam.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.bw')

baseCommand: bamCoverage
arguments:
  - valueFrom: $('--outFileName=' + inputs.bam.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.bw')
    position: 3

description: "Tool:   bedGraphToBigWig v 4 - Convert a bedGraph file to bigWig format."
