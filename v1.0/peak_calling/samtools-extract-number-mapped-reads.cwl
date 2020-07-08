 class: CommandLineTool
 cwlVersion: v1.0
 doc: Extract mapped reads from BAM file using Samtools flagstat command
 requirements:
    InlineJavascriptRequirement: {}
    ShellCommandRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dukegcb/samtools:1.3
 inputs:
    output_suffix:
      type: string
    input_bam_file:
      type: File
      inputBinding:
        position: 1
      doc: Aligned BAM file to filter
 outputs:
    output_read_count:
      type: File
      outputBinding:
        glob: $(inputs.input_bam_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)
      doc: Samtools Flagstat report file
 baseCommand: [samtools, flagstat]
 arguments:
  - valueFrom: " | head -n1 | cut -f 1 -d ' '"
    position: 10000
    shellQuote: false
 stdout: $(inputs.input_bam_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)
