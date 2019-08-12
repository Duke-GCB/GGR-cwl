class: CommandLineTool
cwlVersion: v1.0
doc: |
  AnnotateBamWithUmis
  ------------------------------------------------------------------------------------------------------------------------
  Annotates existing BAM files with UMIs (Unique Molecular Indices, aka Molecular IDs, Molecular barcodes) from a
  separate FASTQ file. Takes an existing BAM file and a FASTQ file consisting of UMI reads, matches the reads between the
  files based on read names, and produces an output BAM file where each record is annotated with an optional tag
  (specified by 'attribute') that contains the read sequence of the UMI. Trailing read numbers ('/1' or '/2') are removed
  from FASTQ read names, as is any text after whitespace, before matching.

  At the end of execution, reports how many records were processed and how many were missing UMIs. If any read from the
  BAM file did not have a matching UMI read in the FASTQ file, the program will exit with a non-zero exit status. The
  '--fail-fast' option may be specified to cause the program to terminate the first time it finds a records without a
  matching UMI.

  In order to avoid sorting the input files, the entire UMI fastq file is read into memory. As a result the program needs
  to be run with memory proportional the size of the (uncompressed) fastq.
requirements:
   InlineJavascriptRequirement: {}
   ShellCommandRequirement: {}
hints:
   DockerRequirement:
     dockerPull: reddylab/fgbio:0.8.1
inputs:
   input:
     type: File
     inputBinding:
       position: 5
       prefix: -i
     doc:  The input SAM or BAM file.
   fastq:
     type: File
     inputBinding:
       position: 5
       prefix: -f
     doc: Input FASTQ file with UMI reads.
   attribute:
     type: string?
     default: RX
     inputBinding:
       position: 5
       prefix: -t
     doc: |
      The BAM attribute to store UMIs in. [Default: RX].
   fail-fast:
     type: boolean?
     inputBinding:
       position: 5
       prefix: --fail-fast
     doc: |
       If set, fail on the first missing UMI. [Default: false].
   outfile:
     type: string?
     doc: Output BAM file to write.
   java_opts:
     type: string?
     inputBinding:
       position: 1
       shellQuote: false
     doc: JVM arguments should be a quoted, space separated list (e.g. "-Xms128m -Xmx512m")
   fgbio_jar_path:
     type: string
     inputBinding:
       position: 2
       prefix: -jar
     doc: Path to the fgbio.jar file
outputs:
   output:
     type: File
     secondaryFiles:
       - ^.bai
     outputBinding:
       glob: |
         ${return inputs.output || inputs.input.nameroot + ".with_umis" + inputs.input.nameext}
baseCommand:
 - java
arguments:
 - valueFrom: $(runtime.tmpdir)
   position: 3
   prefix: --tmp-dir
 - valueFrom: Debug
   position: 3
   prefix: --log-level
 - valueFrom: AnnotateBamWithUmis
   position: 4
 - valueFrom: |
    ${ return runtime.outdir + "/" + (inputs.outfile || inputs.input.nameroot + ".with_umis" + inputs.input.nameext) }
   position: 5
   prefix: --output
