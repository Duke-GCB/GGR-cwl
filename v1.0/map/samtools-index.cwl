 class: CommandLineTool
 cwlVersion: v1.0
 requirements:
    InlineJavascriptRequirement: {}
    InitialWorkDirRequirement:
      listing: [ $(inputs.input_file) ]
 hints:
    DockerRequirement:
      dockerPull: dukegcb/samtools:1.3
 inputs:
    input_file:
      type: File
      inputBinding:
        position: 1
      doc: Aligned file to be sorted with samtools
 outputs:
    indexed_file:
      doc: Indexed BAM file
      type: File
      outputBinding:
        glob: $(inputs.input_file.basename)
      secondaryFiles: .bai
 baseCommand: [samtools, index]
 arguments:
  - valueFrom: $(inputs.input_file.basename + '.bai')
    position: 2
