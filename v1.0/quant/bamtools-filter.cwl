 class: CommandLineTool
 cwlVersion: v1.0
 doc: "Description: filters BAM file(s).\n\n\nUsage: bamtools filter [-in <filename> -in <filename> ... | -list <filelist>] [-out <filename> | [-forceCompression]] [-region <REGION>] [ [-script <filename] | [filterOptions] ]\n\n\nInput & Output:\n\n  -in <BAM filename>                the input BAM file(s) [stdin]\n\n  -list <filename>                  the input BAM file list, one\n\n                                    line per file\n\n  -out <BAM filename>               the output BAM file [stdout]\n\n  -region <REGION>                  only read data from this\n\n                                    genomic region (see documentation for more\n\n                                    details)\n\n  -script <filename>                the filter script file (see\n\n                                    documentation for more details)\n\n  -forceCompression                 if results are sent to stdout\n\n                                    (like when piping to another tool),\n\n                                    default behavior is to leave output\n\n                                    uncompressed. Use this flag to override\n\n                                    and force compression\n\n\n\nGeneral Filters:\n\n  -alignmentFlag <int>              keep reads with this *exact*\n\n                                    alignment flag (for more detailed queries,\n\n                                    see below)\n\n  -insertSize <int>                 keep reads with insert size\n\n                                    that matches pattern\n\n  -mapQuality <[0-255]>             keep reads with map quality\n\n                                    that matches pattern\n\n  -name <string>                    keep reads with name that\n\n                                    matches pattern\n\n  -queryBases <string>              keep reads with motif that\n\n                                    matches pattern\n\n  -tag <TAG:VALUE>                  keep reads with this\n\n                                    key=>value pair\n\n\n\nAlignment Flag Filters:\n\n  -isDuplicate <true/false>         keep only alignments that are\n\n                                    marked as duplicate? [true]\n\n  -isFailedQC <true/false>          keep only alignments that\n\n                                    failed QC? [true]\n\n  -isFirstMate <true/false>         keep only alignments marked as\n\n                                    first mate? [true]\n\n  -isMapped <true/false>            keep only alignments that were\n\n                                    mapped? [true]\n\n  -isMateMapped <true/false>        keep only alignments with\n\n                                    mates that mapped [true]\n\n  -isMateReverseStrand <true/false> keep only alignments with mate\n\n                                    on reverese strand? [true]\n\n  -isPaired <true/false>            keep only alignments that were\n\n                                    sequenced as paired? [true]\n\n  -isPrimaryAlignment <true/false>  keep only alignments marked as\n\n                                    primary? [true]\n\n  -isProperPair <true/false>        keep only alignments that\n\n                                    passed PE resolution? [true]\n\n  -isReverseStrand <true/false>     keep only alignments on\n\n                                    reverse strand? [true]\n\n  -isSecondMate <true/false>        keep only alignments marked as\n\n                                    second mate? [true]\n\n  -isSingleton <true/false>         keep only singletons [true]\n\n\n\nHelp:\n\n  --help, -h                        shows this help text"
 requirements:
    InlineJavascriptRequirement: {}
    ShellCommandRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: reddylab/bamtools:2.2.3
 inputs:
    isMapped:
      type: string?
      inputBinding:
        position: 1
        prefix: -isMapped
      doc: |
        <true/false>            keep only alignments that were
        mapped? [true]
    mapQuality:
      type: string?
      inputBinding:
        position: 1
        prefix: -mapQuality
      doc: |
        <[0-255]>
        keep reads with map quality that matches pattern (e.g. '>50')
    isPaired:
      type: string?
      inputBinding:
        position: 1
        prefix: -isPaired
      doc: |
        <true/false>            keep only alignments that were
        sequenced as paired? [true]
    isFailedQC:
      type: string?
      inputBinding:
        position: 1
        prefix: -isFailedQC
      doc: |
        <true/false>          keep only alignments that
        failed QC? [true]
    isReverseStrand:
      type: string?
      inputBinding:
        position: 1
        prefix: -isReverseStrand
      doc: |
        <true/false>     keep only alignments on
        reverse strand? [true]
    tag:
      type: string?
      inputBinding:
        position: 1
        prefix: -tag
      doc: |
        <TAG:VALUE>
        keep reads with this key=>value pair
    in:
      type: File[]
      inputBinding:
        position: 1
        prefix: -in
      doc: |
        <BAM filename>
        the input BAM file(s) [stdin if omitted]
    isProperPair:
      type: string?
      inputBinding:
        position: 1
        prefix: -isProperPair
      doc: |
        <true/false>        keep only alignments that
        passed PE resolution? [true]
    out:
      type: string?
      inputBinding:
        position: 1
        prefix: -out
      doc: |
        <BAM filename>
        the output BAM filename [stdout ]
    forceCompression:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -forceCompression
      doc: |
        if results are sent to stdout\n(like when piping to another tool),
        default behavior is to leave output
        uncompressed. Use this flag to override
        and force compression.
    script:
      type: File?
      inputBinding:
        position: 1
        prefix: -script
      doc: |
        <filename>
        the filter script file (see documentation for more details)
    isPrimaryAlignment:
      type: string?
      inputBinding:
        position: 1
        prefix: -isPrimaryAlignment
      doc: |
        <true/false>  keep only alignments marked as
        primary? [true]
    alignmentFlag:
      type: int?
      inputBinding:
        position: 1
        prefix: -alignmentFlag
      doc: |
        <int>
        keep reads with this *exact*
        alignment flag (for more detailed queries, see below)
    isDuplicate:
      type: string?
      inputBinding:
        position: 1
        prefix: -isDuplicate
      doc: |
        <true/false>
        keep only alignments that are marked as duplicate? [true]
    isFirstMate:
      type: string?
      inputBinding:
        position: 1
        prefix: -isFirstMate
      doc: |
        <true/false>         keep only alignments marked as
        first mate? [true]
    isSecondMate:
      type: string?
      inputBinding:
        position: 1
        prefix: -isSecondMate
      doc: |
        <true/false>        keep only alignments marked as
        second mate? [true]
    name:
      type: string?
      inputBinding:
        position: 1
        prefix: -name
      doc: |
        <string>
        keep reads with name that matches pattern
    region:
      type: string?
      inputBinding:
        position: 1
        prefix: -region
      doc: |
        <REGION>
        only read data from this
        genomic region (see documentation for more
        details)
    isMateMapped:
      type: string?
      inputBinding:
        position: 1
        prefix: -isMateMapped
      doc: |
        <true/false>        keep only alignments with
        mates that mapped [true]
    insertSize:
      type: int?
      inputBinding:
        position: 1
        prefix: -insertSize
      doc: |
        <int>
        keep reads with insert size that matches pattern
    queryBases:
      type: string?
      inputBinding:
        position: 1
        prefix: -queryBases
      doc: |
        <string>
        keep reads with motif that matches pattern
    isMateReverseStrand:
      type: string?
      inputBinding:
        position: 1
        prefix: -isMateReverseStrand
      doc: |
        <true/false> keep only alignments with mate
        on reverese strand? [true]
    isSingleton:
      type: string?
      inputBinding:
        position: 1
        prefix: -isSingleton
      doc: |
        <true/false>         keep only singletons [true]
        Help:
        --help, -h                        shows this help text
 outputs:
    output_file:
      type: File
      outputBinding:
        glob: $(inputs.out)
 baseCommand:
  - bamtools
  - filter
