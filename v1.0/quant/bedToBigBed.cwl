 class: CommandLineTool
 cwlVersion: v1.0
 doc: |
    "bedToBigBed v. 2.7 - Convert bed file to bigBed. (BigBed version: 4)
    usage:
       bedToBigBed in.bed chrom.sizes out.bb
    Where in.bed is in one of the ascii bed formats, but not including track lines
    and chrom.sizes is two column: <chromosome name> <size in bases>
    and out.bb is the output indexed big bed file.
    Use the script: fetchChromSizes to obtain the actual chrom.sizes information
    from UCSC, please do not make up a chrom sizes from your own information.
    The in.bed file must be sorted by chromosome,start,
      to sort a bed file, use the unix sort command:
         sort -k1,1 -k2,2n unsorted.bed > sorted.bed"
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dleehr/docker-hubutils
 inputs:
    genome_sizes:
      type: File
      inputBinding:
        position: 3
      doc: "genome_sizes is two column: <chromosome name> <size in bases>.\n"
    blockSize:
      type: int?
      inputBinding:
        position: 1
        prefix: -blockSize=
        separate: false
      doc: |
        -blockSize=N - Number of items to bundle in r-tree.  Default 256
    bed:
      type: File
      inputBinding:
        position: 2
      doc: Input bed file
    itemsPerSlot:
      type: int?
      inputBinding:
        position: 1
        prefix: -itemsPerSlot=
        separate: false
      doc: |
        -itemsPerSlot=N - Number of data points bundled at lowest level. Default 512
    as:
      type: File?
      inputBinding:
        position: 1
        prefix: -as=
        separate: false
      doc: |
        -as=fields.as - If you have non-standard "bedPlus" fields, it's great to put a definition
                         of each field in a row in AutoSql format here.1)
    unc:
      type: boolean?
      inputBinding:
        position: 1
      doc: |
        -unc - If set, do not use compression.
    extraIndex:
      type:
      - 'null'
      - {type: array, items: string}
      inputBinding:
        position: 1
        prefix: -extraIndex=
        itemSeparator: ','
      doc: |
        -extraIndex=fieldList - If set, make an index on each field in a comma separated list
           extraIndex=name and extraIndex=name,id are commonly used.
    tab:
      type: boolean?
      inputBinding:
        position: 1
      doc: |
        -tab - If set, expect fields to be tab separated, normally expects white space separator.
    type:
      type: string?
      inputBinding:
        position: 1
        prefix: -type=
        separate: false
      doc: |
        -type=bedN[+[P]] :
                        N is between 3 and 15,
                        optional (+) if extra "bedPlus" fields,
                        optional P specifies the number of extra fields. Not required, but preferred.
                        Examples: -type=bed6 or -type=bed6+ or -type=bed6+3
                        (see http://genome.ucsc.edu/FAQ/FAQformat.html#format1)
    output_suffix:
      type: string
      default: .bb
 outputs:
    bigbed:
      type: File
      outputBinding:
        glob: $(inputs.bed.path.replace(/^.*[\\\/]/, '')+ inputs.output_suffix)
 baseCommand: bedToBigBed
 arguments:
  - valueFrom: $(inputs.bed.path.replace(/^.*[\\\/]/, '') + inputs.output_suffix)
    position: 4
