class: CommandLineTool
cwlVersion: v1.0
requirements:
   InlineJavascriptRequirement: {}
hints:
   DockerRequirement:
     dockerPull: dukegcb/samtools:1.3
inputs:
   b:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -b
     doc: output BAM
   header:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -h
     doc: Include header in output
   f:
     type: int?
     inputBinding:
       position: 1
       prefix: -f
     doc: only include reads with all bits set in INT set in FLAG [0]
   F:
     type: int?
     inputBinding:
       position: 1
       prefix: -F
     doc: only include reads with none of the bits set in INT set in FLAG [0]
   S:
     type: boolean
     default: true
     inputBinding:
       position: 1
       prefix: -S
     doc: Input format autodetected
   nthreads:
     type: int
     default: 1
     inputBinding:
       position: 1
       prefix: -@
     doc: Number of threads used
   input_file:
     type: File
     inputBinding:
       position: 2
     doc: File to be converted to BAM with samtools
   suffix:
     type: string?
     doc: suffix of the transformed SAM/BAM file (including extension, e.g. .filtered.sam)
   outfile_name:
     type: string?
     doc: Output file name. If not specified, the basename of the input file with the suffix specified in the suffix argument will be used.

outputs:
   outfile:
     type: File
     outputBinding:
       glob: |
         ${
           if (inputs.outfile_name) return inputs.outfile_name;
           var suffix = inputs.b ? '.bam' : '.sam';
           suffix = inputs.suffix || suffix;
           return inputs.input_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + suffix
         }
     doc: Aligned file in SAM or BAM format
baseCommand: [samtools, view]
stdout: |
  ${
     if (inputs.outfile_name) return inputs.outfile_name;
     var suffix = inputs.b ? '.bam' : '.sam';
     suffix = inputs.suffix || suffix;
     return inputs.input_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + suffix
  }
