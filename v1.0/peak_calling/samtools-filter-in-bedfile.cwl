 class: CommandLineTool
 cwlVersion: v1.0
 doc: Filter BAM file to only include reads overlapping with a BED file
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dukegcb/samtools:1.3
 inputs:
    input_bam_file:
      type: File
      inputBinding:
        position: 3
      doc: Aligned BAM file to filter
    input_bedfile:
      type: File
      inputBinding:
        position: 2
        prefix: -L
      doc: Bedfile used to only include reads overlapping this BED FILE
 outputs:
    filtered_file:
      type: File
      outputBinding:
        glob: $(inputs.input_bam_file.path.replace(/^.*[\\\/]/, '') + '.in_peaks.bam')
      doc: Filtered aligned BAM file by BED coordinates file
 baseCommand: [samtools, view, -b, -h]
 stdout: $(inputs.input_bam_file.path.replace(/^.*[\\\/]/, '') + '.in_peaks.bam')
