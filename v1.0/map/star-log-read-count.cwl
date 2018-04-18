 class: CommandLineTool
 cwlVersion: v1.0
 doc: Get number of processed reads from STAR log.
 requirements:
    InlineJavascriptRequirement: {}
    ShellCommandRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    star_log: {type: File, inputBinding: {}}
 outputs:
    output:
      type: File
      outputBinding:
        glob: $(inputs.star_log.path.replace(/^.*[\\\/]/, '') + '.read_count.mapped')
 baseCommand: read-count-from-STAR-log.sh
 stdout: $(inputs.star_log.path.replace(/^.*[\\\/]/, '') + '.read_count.mapped')
