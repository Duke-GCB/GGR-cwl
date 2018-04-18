 class: CommandLineTool
 cwlVersion: v1.0
 doc: Get number of processed reads from Bowtie log.
 requirements:
    InlineJavascriptRequirement: {}
    ShellCommandRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    bowtie_log: {type: File, inputBinding: {}}
 outputs:
    output:
      type: File
      outputBinding:
        glob: $(inputs.bowtie_log.path.replace(/^.*[\\\/]/, '') + '.read_count.mapped')
 baseCommand: read-count-from-bowtie-log.sh
 stdout: $(inputs.bowtie_log.path.replace(/^.*[\\\/]/, '') + '.read_count.mapped')
