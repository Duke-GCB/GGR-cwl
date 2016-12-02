#!/usr/bin/env cwl-runner

# Mantainer: alejandro.barrera@duke.edu
# Partially auto generated with clihp (https://github.com/portah/clihp, developed by Andrey.Kartashov@cchmc.org)
# Developed for GGR project (https://github.com/Duke-GCB/GGR-cwl)
cwlVersion: 'cwl:draft-3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/bamtools'
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
inputs:
  - id: in
    type:
      type: array
      items: File
    description: |
      <BAM filename>
      the input BAM file(s) [stdin if omitted]
    inputBinding:
      position: 1
      prefix: '-in'
  - id: out
    type:
      - 'null'
      - string
    description: |
      <BAM filename>
      the output BAM filename [stdout ]
    inputBinding:
      position: 1
      prefix: '-out'
  - id: region
    type:
      - 'null'
      - string
    description: |
      <REGION>
      only read data from this
      genomic region (see documentation for more
      details)
    inputBinding:
      position: 1
      prefix: '-region'
  - id: script
    type:
      - 'null'
      - File
    description: |
      <filename>
      the filter script file (see documentation for more details)
    inputBinding:
      position: 1
      prefix: '-script'
  - id: forceCompression
    type:
      - 'null'
      - boolean
    description: |
      if results are sent to stdout\n(like when piping to another tool),
      default behavior is to leave output
      uncompressed. Use this flag to override
      and force compression.
    inputBinding:
      position: 1
      prefix: '-forceCompression'
  - id: alignmentFlag
    type:
      - 'null'
      - int
    description: |
      <int>
      keep reads with this *exact*
      alignment flag (for more detailed queries, see below)
    inputBinding:
      position: 1
      prefix: '-alignmentFlag'
  - id: insertSize
    type:
      - 'null'
      - int
    description: |
      <int>
      keep reads with insert size that matches pattern
    inputBinding:
      position: 1
      prefix: '-insertSize'
  - id: mapQuality
    type:
      - 'null'
      - string
    description: |
      <[0-255]>
      keep reads with map quality that matches pattern (e.g. '>50')
    inputBinding:
      position: 1
      prefix: '-mapQuality'
  - id: name
    type:
      - 'null'
      - string
    description: |
      <string>
      keep reads with name that matches pattern
    inputBinding:
      position: 1
      prefix: '-name'
  - id: queryBases
    type:
      - 'null'
      - string
    description: |
      <string>
      keep reads with motif that matches pattern
    inputBinding:
      position: 1
      prefix: '-queryBases'
  - id: tag
    type:
      - 'null'
      - string
    description: |
      <TAG:VALUE>
      keep reads with this key=>value pair
    inputBinding:
      position: 1
      prefix: '-tag'
  - id: isDuplicate
    type:
      - 'null'
      - string
    description: |
      <true/false>
      keep only alignments that are marked as duplicate? [true]
    inputBinding:
      position: 1
      prefix: '-isDuplicate'
  - id: isFailedQC
    type:
      - 'null'
      - string
    description: |
      <true/false>          keep only alignments that
      failed QC? [true]
    inputBinding:
      position: 1
      prefix: '-isFailedQC'
  - id: isFirstMate
    type:
      - 'null'
      - string
    description: |
      <true/false>         keep only alignments marked as
      first mate? [true]
    inputBinding:
      position: 1
      prefix: '-isFirstMate'
  - id: isMapped
    type:
      - 'null'
      - string
    description: |
      <true/false>            keep only alignments that were
      mapped? [true]
    inputBinding:
      position: 1
      prefix: '-isMapped'
  - id: isMateMapped
    type:
      - 'null'
      - string
    description: |
      <true/false>        keep only alignments with
      mates that mapped [true]
    inputBinding:
      position: 1
      prefix: '-isMateMapped'
  - id: isMateReverseStrand
    type:
      - 'null'
      - string
    description: |
      <true/false> keep only alignments with mate
      on reverese strand? [true]
    inputBinding:
      position: 1
      prefix: '-isMateReverseStrand'
  - id: isPaired
    type:
      - 'null'
      - string
    description: |
      <true/false>            keep only alignments that were
      sequenced as paired? [true]
    inputBinding:
      position: 1
      prefix: '-isPaired'
  - id: isPrimaryAlignment
    type:
      - 'null'
      - string
    description: |
      <true/false>  keep only alignments marked as
      primary? [true]
    inputBinding:
      position: 1
      prefix: '-isPrimaryAlignment'
  - id: isProperPair
    type:
      - 'null'
      - string
    description: |
      <true/false>        keep only alignments that
      passed PE resolution? [true]
    inputBinding:
      position: 1
      prefix: '-isProperPair'
  - id: isReverseStrand
    type:
      - 'null'
      - string
    description: |
      <true/false>     keep only alignments on
      reverse strand? [true]
    inputBinding:
      position: 1
      prefix: '-isReverseStrand'
  - id: isSecondMate
    type:
      - 'null'
      - string
    description: |
      <true/false>        keep only alignments marked as
      second mate? [true]
    inputBinding:
      position: 1
      prefix: '-isSecondMate'
  - id: isSingleton
    type:
      - 'null'
      - string
    description: |
      <true/false>         keep only singletons [true]
      Help:
      --help, -h                        shows this help text
    inputBinding:
      position: 1
      prefix: '-isSingleton'
outputs:
  - id: output_file
    type: File
    outputBinding:
      glob: $(inputs.out)
baseCommand:
  - bamtools
  - filter
description: >-
  Description: filters BAM file(s).



  Usage: bamtools filter [-in <filename> -in <filename> ... | -list <filelist>]
  [-out <filename> | [-forceCompression]] [-region <REGION>] [ [-script
  <filename] | [filterOptions] ]



  Input & Output:

    -in <BAM filename>                the input BAM file(s) [stdin]

    -list <filename>                  the input BAM file list, one

                                      line per file

    -out <BAM filename>               the output BAM file [stdout]

    -region <REGION>                  only read data from this

                                      genomic region (see documentation for more

                                      details)

    -script <filename>                the filter script file (see

                                      documentation for more details)

    -forceCompression                 if results are sent to stdout

                                      (like when piping to another tool),

                                      default behavior is to leave output

                                      uncompressed. Use this flag to override

                                      and force compression



  General Filters:

    -alignmentFlag <int>              keep reads with this *exact*

                                      alignment flag (for more detailed queries,

                                      see below)

    -insertSize <int>                 keep reads with insert size

                                      that matches pattern

    -mapQuality <[0-255]>             keep reads with map quality

                                      that matches pattern

    -name <string>                    keep reads with name that

                                      matches pattern

    -queryBases <string>              keep reads with motif that

                                      matches pattern

    -tag <TAG:VALUE>                  keep reads with this

                                      key=>value pair



  Alignment Flag Filters:

    -isDuplicate <true/false>         keep only alignments that are

                                      marked as duplicate? [true]

    -isFailedQC <true/false>          keep only alignments that

                                      failed QC? [true]

    -isFirstMate <true/false>         keep only alignments marked as

                                      first mate? [true]

    -isMapped <true/false>            keep only alignments that were

                                      mapped? [true]

    -isMateMapped <true/false>        keep only alignments with

                                      mates that mapped [true]

    -isMateReverseStrand <true/false> keep only alignments with mate

                                      on reverese strand? [true]

    -isPaired <true/false>            keep only alignments that were

                                      sequenced as paired? [true]

    -isPrimaryAlignment <true/false>  keep only alignments marked as

                                      primary? [true]

    -isProperPair <true/false>        keep only alignments that

                                      passed PE resolution? [true]

    -isReverseStrand <true/false>     keep only alignments on

                                      reverse strand? [true]

    -isSecondMate <true/false>        keep only alignments marked as

                                      second mate? [true]

    -isSingleton <true/false>         keep only singletons [true]



  Help:

    --help, -h                        shows this help text

