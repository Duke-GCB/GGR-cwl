 class: CommandLineTool
 cwlVersion: v1.0
 doc: |
    Merge the STAR 1-pass novel splice junction databases ('SJ.out.tab').
    Save only those splice junctions in autosomes and sex chromosomes.
    Filter out splice junctions that are non-canonical, supported by only 10 or fewer reads.
 requirements:
    InlineJavascriptRequirement: {}
    ShellCommandRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dukegcb/star-utils
 inputs:
    sjdb_out_filename:
      type: string
      inputBinding:
        position: 2
    sjdb_files:
      type: File[]
      inputBinding:
        position: 1
        itemSeparator: ','
 outputs:
    sjdb_out:
      type: File
      outputBinding:
        glob: $(inputs.sjdb_out_filename)
 baseCommand: create_SJ.out.tab.Pass1.conservative.sjdb.py
