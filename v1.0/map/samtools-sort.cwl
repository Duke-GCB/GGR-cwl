class: CommandLineTool
cwlVersion: v1.0
requirements:
   InlineJavascriptRequirement: {}
hints:
   DockerRequirement:
     dockerPull: dukegcb/samtools:1.3
inputs:
   n:
     type: boolean
     default: false
     inputBinding:
       position: 1
       prefix: -n
     doc: Sort by read name
   nthreads:
     type: int
     default: 1
     inputBinding:
       position: 1
       prefix: -@
     doc: Number of threads used in sorting
   input_file:
     type: File
     inputBinding:
       position: 1000
     doc: Aligned file to be sorted with samtools
   suffix:
     type: string
     default: .sorted.bam
     doc: suffix of the transformed SAM/BAM file (including extension, e.g. .filtered.sam)

outputs:
   sorted_file:
     type: File
     outputBinding:
       glob: $(inputs.input_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + inputs.suffix)
     doc: Sorted aligned file
baseCommand: [samtools, sort]
stdout: $(inputs.input_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + inputs.suffix)
arguments:
   - valueFrom: $(runtime.tmpdir)
     position: 3
     prefix: '-T'
