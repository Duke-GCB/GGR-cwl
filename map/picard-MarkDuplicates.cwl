#!/usr/bin/env cwl-runner

cwlVersion: 'cwl:draft-3.dev3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerImageId: 'dukegcb/picard'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement


inputs:
  - id: "#input_file"
    type: File
    description: 'One or more input SAM or BAM files to analyze. Must be coordinate sorted.'
    inputBinding:
      position: 4
      valueFrom: $('INPUT=' + self.path)
      shellQuote: false

  - id: "#java_Xms"
    type: string
    description: "Starting memory allocation pool for a Java Virtual Machine (JVM)"
    default: "-Xms512m"
    inputBinding:
      position: 1
  - id: "#java_Xmx"
    type: string
    description: "Maximum memory allocation pool for a Java Virtual Machine (JVM)"
    default: "-Xmx2000m"
    inputBinding:
      position: 1
  - id: "#absolute_path_to_picard_jar"
    type: string
    description: 'Absolute path to the picard.jar file (Required for compatibility with docker)'
    inputBinding:
      position: 2
      prefix: "-jar"
  - id: "#remove_duplicates"
    type: boolean
    description: "If true do not write duplicates to the output file instead of writing them with appropriate flags set.  (Default true)."
    default: true
    inputBinding:
      valueFrom: $('REMOVE_DUPLICATES=' + self)
      position: 5
  - id: "#output_suffix"
    type: string
    description: "Suffix used to identify the output file (Default: dedup.bam)"
    default: "dedup.bam"
  - id: "#metrics_suffix"
    type: string
    description: "Suffix used to create the metrics output file (Default: dedup_metrics.txt)"
    default: "dedup_metrics.txt"

outputs:
  - id: '#output_metrics_file'
    type: File
    outputBinding:
      glob: $(inputs.input_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.' + inputs.metrics_suffix)
  - id: '#output_dedup_bam_file'
    type: File
    outputBinding:
      glob: $(inputs.input_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.')  + '.' + inputs.output_suffix)

baseCommand: ["java"]
arguments:
  - valueFrom: "MarkDuplicates"
    position: 3
  - valueFrom: $('OUTPUT=' + inputs.input_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.' + inputs.output_suffix)
    position: 5
    shellQuote: false
  - valueFrom: $('METRICS_FILE='+inputs.input_file.path.split('/').slice(-1)[0].split('\.').slice(0,-1).join('.') + '.' + inputs.metrics_suffix)
    position: 5
    shellQuote: false

# remove duplicates
#java -Xms12000m -Xmx12000m -jar /data/reddylab/software/picard/dist/picard.jar MarkDuplicates \
#INPUT=${SAMPLE}.accepted_hits.bam \
#OUTPUT=${SAMPLE}.dedup.bam \
#METRICS_FILE=picard.${SAMPLE}_dedup_metrics.txt \
#REMOVE_DUPLICATES=TRUE CREATE_INDEX=TRUE