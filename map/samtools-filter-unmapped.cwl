#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/samtools'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: "#input_file"
    type: File
    description: "Aligned file to be sorted with samtools"
    inputBinding:
      position: 1

outputs:
  - id: "#filtered_file"
    type: File
    description: "Filter unmapped reads in aligned file"
    outputBinding:
      glob: "*.accepted_hits"
      outputEval: $(self[0])

baseCommand: ["samtools", "view", "-F", "4", "-b", "-h" ]
stdout: $(inputs.input_file.path.split('/').slice(-1)[0] + '.accepted_hits')

#samtools view -F 4 -b -h -o ${SAMPLE}.accepted_hits.bam ${SAMPLE}.sorted.bam