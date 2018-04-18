 class: CommandLineTool
 cwlVersion: v1.0
 doc: Trunk scores in ENCODE bed6+4 files
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    peaks:
      type: File
      inputBinding:
        position: 10000
    sep:
      type: string
      default: \t
      inputBinding:
        position: 2
        prefix: -F
 outputs:
    trunked_scores_peaks:
      type: File
      outputBinding:
        glob: $(inputs.peaks.path.replace(/^.*[\\\/]/, '').replace(/\.([^/.]+)$/, "\.trunked_scores\.$1"))
 baseCommand: awk
 arguments:
  - valueFrom: BEGIN{OFS=FS}$5>1000{$5=1000}{print}
    position: 3
 stdout: $(inputs.peaks.path.replace(/^.*[\\\/]/, '').replace(/\.([^/.]+)$/, "\.trunked_scores\.$1"))
