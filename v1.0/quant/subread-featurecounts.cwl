 class: CommandLineTool
 cwlVersion: v1.0
 doc: featureCounts is a highly efficient general-purpose read summarization program that counts mapped reads for genomic features such as genes, exons, promoter, gene bodies, genomic bins and chromosomal locations. It can be used to count both RNA-seq and genomic DNA-seq reads.
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: reddylab/subread:1.4.6-p4
 inputs:
    primary:
      type: boolean?
      inputBinding:
        position: 1
        prefix: --primary
      doc: "\tIf specified, only primary alignments will be counted. Primary\nand secondary alignments are identified using bit 0x100 in the\nFlag field of SAM/BAM files. All primary alignments in a dataset\nwill be counted no matter they are from multi-mapping reads or\nnot ('-M' is ignored).\n"
    output_filename:
      type: string
      inputBinding:
        position: 3
        prefix: -o
      doc: |
        -o <input>
        Give the name of the output file. The output file contains
        the number of reads assigned to each meta-feature (or each
        feature if -f is specified). A meta-feature is the aggregation
        of features, grouped by using gene identifiers. Please refer
        to the users guide for more details.
    read2pos:
      type: int?
      inputBinding:
        position: 1
        prefix: --read2pos
      doc: |
        <5:3>            The read is reduced to its 5' most base or 3'
        most base. Read summarization is then performed based on the
        single base which the read is reduced to.
    B:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -B
      doc: "       \tIf specified, only fragments that have both ends \nsuccessfully aligned will be considered for summarization.\nThis option is only applicable for paired-end reads.\n"
    ignoreDup:
      type: boolean?
      inputBinding:
        position: 1
        prefix: --ignoreDup
      doc: "\tIf specified, reads that were marked as\nduplicates will be ignored. Bit Ox400 in FLAG field of SAM/BAM\nfile is used for identifying duplicate reads. In paired end\ndata, the entire read pair will be ignored if at least one end\nis found to be a duplicate read.\n"
    fraction:
      type: boolean?
      inputBinding:
        position: 1
        prefix: --fraction
      doc: |
        If specified, a fractional count 1/n will be generated for each
        multi-mapping read, where n is the number of alignments (indica-
        ted by 'NH' tag) reported for the read. This option must be used
        together with the '-M' option.
    A:
      type: File?
      inputBinding:
        position: 1
        prefix: -A
      doc: "<input>\tSpecify the name of a file including aliases of chromosome\nnames. The file should be a comma delimited text file that\nincludes two columns. The first column gives the chromosome\nnames used in the annotation and the second column gives the\nchromosome names used by reads. This file should not contain\nheader lines. Names included in this file are case sensitive.\n"
    C:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -C
      doc: "       \tIf specified, the chimeric fragments (those fragments that \nhave their two ends aligned to different chromosomes) will\nNOT be included for summarization. This option is only\napplicable for paired-end read data.\n"
    countSplitAlignmentsOnly:
      type: boolean?
      inputBinding:
        position: 1
        prefix: --countSplitAlignmentsOnly
      doc: "\tIf specified, only split alignments (CIGAR\nstrings containing letter `N') will be counted. All the other\nalignments will be ignored. An example of split alignments is\nthe exon-spanning reads in RNA-seq data.\nOptional paired-end parameters:\n"
    D:
      type: int?
      inputBinding:
        position: 1
        prefix: -D
      doc: "<int>  \tMaximum fragment/template length, 600 by default.\n"
    F:
      type: string?
      inputBinding:
        position: 1
        prefix: -F
      doc: "<input>\tSpecify the format of the annotation file. Acceptable formats\ninclude `GTF' and `SAF'. `GTF' by default. Please refer to the\nusers guide for SAF annotation format.\n"
    v:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -v
      doc: "       \tOutput version of the program.\n"
    M:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -M
      doc: "       \tIf specified, multi-mapping reads/fragments will be counted (ie.\na multi-mapping read will be counted up to N times if it has N\nreported mapping locations). The program uses the `NH' tag to\nfind multi-mapping reads.\n"
    O:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -O
      doc: "       \tIf specified, reads (or fragments if -p is specified) will\nbe allowed to be assigned to more than one matched meta-\nfeature (or feature if -f is specified).\n"
    Q:
      type: int?
      inputBinding:
        position: 1
        prefix: -Q
      doc: "<int>  \tThe minimum mapping quality score a read must satisfy in order\nto be counted. For paired-end reads, at least one end should\nsatisfy this criteria. 0 by default.\n"
    P:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -P
      doc: "       \tIf specified, paired-end distance will be checked when assigning\nfragments to meta-features or features. This option is only\napplicable when -p is specified. The distance thresholds should\nbe specified using -d and -D options.\n"
    readExtension5:
      type: int?
      inputBinding:
        position: 1
        prefix: --readExtension5
      doc: |
        <int>      Reads are extended upstream by <int> bases from
        their 5' end.
    readExtension3:
      type: int?
      inputBinding:
        position: 1
        prefix: --readExtension3
      doc: |
        <int>      Reads are extended upstream by <int> bases from
        their 3' end.
    T:
      type: int?
      inputBinding:
        position: 1
        prefix: -T
      doc: "<int>  \tNumber of the threads. 1 by default.\n"
    minReadOverlap:
## >>> Currently not supported <<<
#  - id: R
#    type:
#      - 'null'
#      - boolean
#    description: "       \tOutput read counting result for each read/fragment. For each\ninput read file, read counting results for reads/fragments will\nbe saved to a tab-delimited file that contains four columns\nincluding read name, status(assigned or the reason if not\nassigned), name of target feature/meta-feature and number of\nhits if the read/fragment is counted multiple times. Name of\nthe file is the same as name of the input read file except a\nsuffix `.featureCounts' is added.\n"
#    inputBinding:
#      position: 1
#      prefix: '-R'
## >>> Currently not supported <<<
      type: int?
      inputBinding:
        position: 1
        prefix: --minReadOverlap
      doc: |
        <int>      Specify the minimum number of overlapped bases
        required to assign a read to a feature. 1 by default. Negative
        values are permitted, indicating a gap being allowed between a
        read and a feature.
    input_files:
      type: File[]
      inputBinding:
        position: 4
      doc: |
        <input_files>
        Give the names of input read files that include the read
        mapping results. Format of input files is automatically
        determined (SAM or BAM). Paired-end reads will be
        automatically re-ordered if it is found that reads from the
        same pair are not adjacent to each other. Multiple files can
        be provided at the same time.
    d:
      type: int?
      inputBinding:
        position: 1
        prefix: -d
      doc: "<int>  \tMinimum fragment/template length, 50 by default.\n"
    g:
      type: string?
      inputBinding:
        position: 1
        prefix: -g
      doc: "<input>\tSpecify the attribute type used to group features (eg. exons)\ninto meta-features (eg. genes), when GTF annotation is provided.\n`gene_id' by default. This attribute type is usually the gene\nidentifier. This argument is useful for the meta-feature level\nsummarization.\n"
    f:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -f
      doc: "       \tIf specified, read summarization will be performed at the \nfeature level (eg. exon level). Otherwise, it is performed at\nmeta-feature level (eg. gene level).\n"
    p:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -p
      doc: "       \tIf specified, fragments (or templates) will be counted instead\nof reads. This option is only applicable for paired-end reads.\nThe two reads from the same fragment must be adjacent to each\nother in the provided SAM/BAM file.\n"
    s:
      type: int?
      inputBinding:
        position: 1
        prefix: -s
      doc: "<int>  \tIndicate if strand-specific read counting should be performed.\nIt has three possible values:  0 (unstranded), 1 (stranded) and\n2 (reversely stranded). 0 by default.\n"
    donotsort:
      type: boolean?
      inputBinding:
        position: 1
        prefix: --donotsort
      doc: "  If specified, paired end reads will not be reordered even if\nreads from the same pair were found not to be next to each other\nin the input.\n"
    t:
      type: string?
      inputBinding:
        position: 1
        prefix: -t
      doc: "<input>\tSpecify the feature type. Only rows which have the matched\nmatched feature type in the provided GTF annotation file\nwill be included for read counting. `exon' by default.\n"
    annotation_file:
      type: File
      inputBinding:
        position: 2
        prefix: -a
      doc: |
        -a <input>
        Give the name of the annotation file. The program assumes
        that the provided annotation file is in GTF format. Use -F
        option to specify other annotation formats.
 outputs:
    output_files:
      type: File
      outputBinding:
        glob: $(inputs.output_filename)
 baseCommand:
  - featureCounts
