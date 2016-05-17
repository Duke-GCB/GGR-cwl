#!/usr/bin/env cwl-runner

cwlVersion: 'cwl:draft-3'
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
    description: "\t Normalize read counts by RPKM. \n"
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
  - id: "#nthreads"
    type:
      - 'null'
      - int
    description: "Number of processors to use. (default max/2 available processors)"
    inputBinding:
      position: 1
      prefix: "-p"
  - id: "#output_suffix"
    type: string
    default: ".bw"
    description: "Suffix used for output file name (input basename + suffix)"

outputs:
  - id: '#output_bam_coverage'
    type: File
    outputBinding:
      glob: $(inputs.bam.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + inputs.output_suffix)

baseCommand: bamCoverage
arguments:
  - valueFrom: $('--outFileName=' + inputs.bam.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + inputs.output_suffix)
    position: 3

description: "Tool:   bedGraphToBigWig v 4 - Convert a bedGraph file to bigWig format."
