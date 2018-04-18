 class: CommandLineTool
 cwlVersion: v1.0
 doc: "Usage: c_curve [OPTIONS] <sorted-bed-file>\n\nOptions:\n  -o, -output   yield output file (default: stdout) \n  -s, -step     step size in extrapolations (default: 1e+06) \n  -v, -verbose  print more information \n  -P, -pe       input is paired end read file \n  -H, -hist     input is a text file containing the observed histogram \n  -V, -vals     input is a text file containing only the observed counts \n  -B, -bam      input is in BAM format \n  -l, -seg_len  maximum segment length when merging paired end bam reads \n                (default: 5000) \n\nHelp options:\n  -?, -help     print this help message \n      -about    print about message"
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: reddylab/preseq:2.0
 inputs:
    V:
      type: File?
      inputBinding:
        position: 1
        prefix: -V
      doc: "-vals     input is a text file containing only the observed counts \n"
    B:
      type: boolean
      default: true
      inputBinding:
        position: 1
        prefix: -B
      doc: "-bam      input is in BAM format \n"
    output_file_basename:
      type: string
    H:
      type: File?
      inputBinding:
        position: 1
        prefix: -H
      doc: "-hist     input is a text file containing the observed histogram \n"
    v:
      type: boolean
      default: false
      inputBinding:
        position: 1
        prefix: -v
      doc: "-verbose  print more information \n"
    input_sorted_file:
      type: File
      inputBinding:
        position: 2
      doc: Sorted bed or BAM file
    l:
      type: int?
      inputBinding:
        position: 1
        prefix: -l
      doc: "-seg_len  maximum segment length when merging paired end bam reads \n(default: 5000)\nHelp options:\n-?, -help     print this help message\n-about    print about message\n"
    s:
      type: float?
      inputBinding:
        position: 1
        prefix: -s
      doc: "-step     step size in extrapolations (default: 1e+06) \n"
    pe:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -P
      doc: "-pe       input is paired end read file \n"
 outputs:
    output_file:
      type: File
      outputBinding:
        glob: $(inputs.output_file_basename + '.preseq_c_curve.txt')
 baseCommand:
  - preseq
  - c_curve
 stdout: $(inputs.output_file_basename + '.preseq_c_curve.txt')
