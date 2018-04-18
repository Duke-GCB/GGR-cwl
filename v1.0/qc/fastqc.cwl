 class: CommandLineTool
 cwlVersion: v1.0
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dukegcb/fastqc
 inputs:
    format:
      type: string
      default: fastq
      inputBinding:
        position: 3
        prefix: --format
    threads:
      type: int
      default: 1
      inputBinding:
        position: 5
        prefix: --threads
    noextract:
      type: boolean
      default: true
      inputBinding:
        prefix: --noextract
        position: 2
    input_fastq_file:
      type: File
      inputBinding:
        position: 4
 outputs:
    output_qc_report_file:
      type: File
      outputBinding:
        glob: $(inputs.input_fastq_file.path.replace(/^.*[\\\/]/, "").replace(/\.[^/.]+$/, '') + "_fastqc.zip")
 baseCommand: fastqc
 arguments:
  - valueFrom: $(runtime.tmpdir)
    prefix: --dir
    position: 5
  - valueFrom: $(runtime.outdir)
    prefix: -o
    position: 5
