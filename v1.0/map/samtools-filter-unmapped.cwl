 class: CommandLineTool
 cwlVersion: v1.0
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dukegcb/samtools
 inputs:
    nthreads:
      type: int
      default: 1
      inputBinding:
        position: 1
        prefix: -@
      doc: Number of threads used in sorting
    output_filename:
      type: string
      doc: Basename for the output file
    input_file:
      type: File
      inputBinding:
        position: 1000
      doc: Aligned file to be sorted with samtools
 outputs:
    filtered_file:
      type: File
      outputBinding:
        glob: $(inputs.output_filename + '.accepted_hits.bam')
      doc: Filter unmapped reads in aligned file
 baseCommand: [samtools, view, -F, '4', -b, -h]
 stdout: $(inputs.output_filename + '.accepted_hits.bam')
