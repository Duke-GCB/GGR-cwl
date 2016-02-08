#!/usr/bin/env cwl-runner

class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/bowtie'

inputs:
  - id: "#t"
    type: boolean
    default: true
    inputBinding:
      position: 1
      prefix: "-t"
  - id: "#m"
    type: int
    default: 1
    inputBinding:
      position: 7
      prefix: "-m"
  - id: "#v"
    type: int
    default: 2
    inputBindng:
      position: 3
      prefix: "-v"
  - id: "#X"
    type: int
    default: 2000
    inputBinding:
      position: 4
      prefix: "-X"
  - id: "#best"
    type: boolean
    default: true
    inputBinding:
      position: 5
      prefix: "--best"
  - id: "#strata"
    type: boolean
    default: true
    inputBinding:
      position: 6
      prefix: "--strata"
  - id: "#sam"
    type: boolean
    default: true
    inputBinding:
      position: 2
      prefix: "--sam"
  - id: "#threads"
    type: int
    default: 1
    inputBinding:
      position: 8
      prefix: "--threads"
  - id: "#genome_ref_index_files"
    type:
      type: array
      items: File
  - id: "#input_fastq_file"
    type: File
    inputBinding:
      position: 10
  - id: "#output_filename"
    type: string
    default: "out.sam"

outputs:
  - id: "#output_aligned_file"
    type: File
    outputBinding:
      glob: "*.sam"
      outputEval: $(self[0])


baseCommand: bowtie
arguments:
  - valueFrom: $(inputs.genome_ref_index_files[0].path.split('.').splice(0,inputs.genome_ref_index_files[0].path.split('.').length-2).join("."))
    position: 9
  - valueFrom: $(inputs.output_filename.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.sam')
    position: 11

#      /data/reddylab/software/bowtie-0.12.9/bowtie -t -m 1 -v 2 --best --strata --sam --threads $THREADS -X 2000 \
#      -q $GENOME_REF \
#      ${DATA_DIR}/${SAMPLE}.trimmed.fastq \
#      ${SAMPLE}.sam \
#      2> bowtie.${SAMPLE}.stats.txt