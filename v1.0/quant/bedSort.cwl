 class: CommandLineTool
 cwlVersion: v1.0
 doc: |
    bedSort - Sort a .bed file by chrom,chromStart
    usage:
       bedSort in.bed out.bed
    in.bed and out.bed may be the same.
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dleehr/docker-hubutils
 inputs:
    bed_file:
      type: File
      inputBinding:
        position: 1
      doc: Bed or bedGraph file to be sorted
 outputs:
    bed_file_sorted:
      type: File
      outputBinding:
        glob: $(inputs.bed_file.path.replace(/^.*[\\\/]/, '') + "_sorted")
 baseCommand: bedSort
 arguments:
  - valueFrom: $(inputs.bed_file.path.replace(/^.*[\\\/]/, '') + "_sorted")
    position: 2
