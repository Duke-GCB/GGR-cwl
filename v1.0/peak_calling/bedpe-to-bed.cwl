 class: CommandLineTool
 cwlVersion: v1.0
 doc: Un-pack a BEDPE concatenating both mates so that they are treated independently
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    bedpe:
      type: File
      inputBinding:
        position: 1
 outputs:
    bed:
      type: File
      outputBinding:
        glob: $(inputs.bedpe.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '').replace(/([_\.]?sorted)*$/, '.unpaired.bed'))
 baseCommand: bedpe-to-bed.sh
 stdout: $(inputs.bedpe.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '').replace(/([_\.]?sorted)*$/, '.unpaired.bed'))
