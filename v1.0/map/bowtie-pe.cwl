class: CommandLineTool
cwlVersion: v1.0
requirements:
   InlineJavascriptRequirement: {}
   ShellCommandRequirement: {}
hints:
   DockerRequirement:
     dockerPull: reddylab/bowtie:1.2.3
inputs:
   nthreads:
     type: int
     default: 1
     inputBinding:
       position: 8
       prefix: --threads
     doc: '<int> number of alignment threads to launch (default: 1)'
   sam:
     type: boolean
     default: true
     inputBinding:
       position: 2
       prefix: --sam
     doc: 'Write hits in SAM format (default: BAM)'
   seedmms:
     type: int?
     inputBinding:
       position: 1
       prefix: --seedmms
     doc: 'max mismatches in seed (between [0, 3], default: 2)'
   m:
     type: int
     default: 1
     inputBinding:
       position: 7
       prefix: -m
     doc: 'Suppress all alignments if > <int> exist (def: 1)'
   strata:
     type: boolean
     default: true
     inputBinding:
       position: 6
       prefix: --strata
     doc: Hits in sub-optimal strata aren't reported (requires --best)
   output_filename:
     type: string
   seedlen:
     type: int?
     inputBinding:
       position: 1
       prefix: --seedlen
     doc: 'seed length for -n (default: 28)'
   input_fastq_read2_file:
     type: File
     inputBinding:
       position: 11
       prefix: '-2'
     doc: Query input FASTQ file.
   t:
     type: boolean
     default: true
     inputBinding:
       position: 1
       prefix: -t
     doc: Print wall-clock time taken by search phases
   v:
     type: int?
     default: 2
     inputBinding:
       position: 3
       prefix: -v
     doc: Report end-to-end hits w/ <=v mismatches; ignore qualities
   X:
     type: int?
     default: 2000
     inputBinding:
       position: 4
       prefix: -X
     doc: 'maximum insert size for paired-end alignment (default: 2000)'
   trim3:
     type: int?
     inputBinding:
       position: 1
       prefix: --trim3
     doc: trim <int> bases from 3' (right) end of reads
   genome_ref_first_index_file:
     type: File
     secondaryFiles:
     - ^^.2.ebwt
     - ^^.3.ebwt
     - ^^.4.ebwt
     - ^^.rev.1.ebwt
     - ^^.rev.2.ebwt
     inputBinding:
       position: 9
       valueFrom: $(self.path.split('.').splice(0,self.path.split('.').length-2).join("."))
     doc: First file (extension .1.ebwt) of the Bowtie index files generated for the reference genome (see http://bowtie-bio.sourceforge.net/tutorial.shtml#newi)
   trim5:
     type: int?
     inputBinding:
       position: 1
       prefix: --trim5
     doc: trim <int> bases from 5' (left) end of reads
   chunkmbs:
     type: int?
     inputBinding:
       position: 5
       prefix: --chunkmbs
     doc: 'The number of megabytes of memory a given thread is given to store path descriptors in --best mode. (Default: 256)'
   best:
     type: boolean
     default: true
     inputBinding:
       position: 5
       prefix: --best
     doc: Hits guaranteed best stratum; ties broken by quality
   input_fastq_read1_file:
     type: File
     inputBinding:
       position: 10
       prefix: '-1'
     doc: Query input FASTQ file.
outputs:
   output_aligned_file:
     type: File
     outputBinding:
       glob: $(inputs.output_filename + '.sam')
     doc: Aligned bowtie file in [SAM|BAM] format.
   output_bowtie_log:
     type: File
     outputBinding:
       glob: $(inputs.output_filename + '.bowtie.log')
baseCommand: bowtie
stderr: $(inputs.output_filename + '.bowtie.log')
arguments:
 - valueFrom: $(inputs.output_filename + '.sam')
   position: 12
