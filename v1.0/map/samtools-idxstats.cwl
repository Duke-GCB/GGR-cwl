class: CommandLineTool
cwlVersion: v1.0
requirements:
   InlineJavascriptRequirement: {}
   InitialWorkDirRequirement:
     listing: [ $(inputs.bam) ]
hints:
   DockerRequirement:
     dockerPull: dukegcb/samtools:1.3
inputs:
   bam:
     type: File
     inputBinding:
       position: 1
     secondaryFiles:
      - .bai
     doc: Bam file (it should be indexed)
outputs:
   idxstats_file:
     type: File
     doc: |
      Idxstats output file. TAB-delimited with each line consisting of reference
      sequence name, sequence length, # mapped reads and # unmapped reads
     outputBinding:
       glob: $(inputs.bam.basename + ".idxstats")
baseCommand: [samtools, idxstats]
stdout: $(inputs.bam.basename + ".idxstats")