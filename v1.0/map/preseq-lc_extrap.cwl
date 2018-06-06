class: CommandLineTool
cwlVersion: v1.0
doc: "Usage: lc_extrap [OPTIONS] <sorted-bed-file>\n\nOptions:\n  -o, -output      yield output file (default: stdout) \n  -e, -extrap      maximum extrapolation (default: 1e+10) \n  -s, -step        step size in extrapolations (default: 1e+06) \n  -n, -bootstraps  number of bootstraps (default: 100), \n  -c, -cval        level for confidence intervals (default: 0.95) \n  -x, -terms       maximum number of terms \n  -v, -verbose     print more information \n  -B, -bam         input is in BAM format \n  -l, -seg_len     maximum segment length when merging paired end bam reads \n                   (default: 5000) \n  -P, -pe          input is paired end read file \n  -V, -vals        input is a text file containing only the observed counts \n  -H, -hist        input is a text file containing the observed histogram \n  -Q, -quick       quick mode, estimate yield without bootstrapping for \n                   confidence intervals \n  -D, -defects     defects mode to extrapolate without testing for defects \n\nHelp options:\n  -?, -help        print this help message \n      -about       print about message"
requirements:
   InlineJavascriptRequirement: {}
hints:
   DockerRequirement:
     dockerPull: reddylab/preseq:2.0
inputs:
   c:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -c
     doc: "-cval        level for confidence intervals (default: 0.95) \n"
   B:
     type: boolean
     default: true
     inputBinding:
       position: 1
       prefix: -B
     doc: "-bam         input is in BAM format \n"
   e:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -e
     doc: "-extrap      maximum extrapolation (default: 1e+10) \n"
   output_file_basename:
     type: string
   H:
     type: string?
     inputBinding:
       position: 1
       prefix: -H
     doc: "-hist        input is a text file containing the observed histogram \n"
   pe:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -P
     doc: "-pe          input is paired end read file \n"
   input_sorted_file:
     type: File
     inputBinding:
       position: 2
     doc: Sorted bed or BAM file
   l:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -l
     doc: "-seg_len     maximum segment length when merging paired end bam reads \n(default: 5000)\n"
   n:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -n
     doc: "-bootstraps  number of bootstraps (default: 100), \n"
   Q:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -Q
     doc: "-quick       quick mode, estimate yield without bootstrapping for \nconfidence intervals\n"
   s:
     type: float?
     inputBinding:
       position: 1
       prefix: -s
     doc: "-step        step size in extrapolations (default: 1e+06) \n"
   v:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -v
     doc: "-verbose     print more information \n"
   x:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -x
     doc: "-terms       maximum number of terms \n"
   V:
     type: string?
     inputBinding:
       position: 1
       prefix: -V
     doc: "-vals        input is a text file containing only the observed counts \n"
   D:
     type: boolean
     default: false
     inputBinding:
       position: 1
       prefix: -D
     doc: "-defects     defects mode to extrapolate without testing for defects \n"
outputs:
   output_file:
     type: File
     outputBinding:
       glob: $(inputs.output_file_basename + '.preseq_lc_extrap.txt')
baseCommand:
 - preseq
 - lc_extrap
stdout: $(inputs.output_file_basename + '.preseq_lc_extrap.txt')
