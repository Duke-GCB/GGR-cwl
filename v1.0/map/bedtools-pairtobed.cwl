 class: CommandLineTool
 cwlVersion: v1.0
 doc: "Tool:    bedtools pairtobed (aka pairToBed)\nVersion: v2.25.0\nSummary: Report overlaps between a BEDPE file and a BED/GFF/VCF file.\n\nUsage:   bedtools pairtobed [OPTIONS] -a <bedpe> -b <bed/gff/vcf>\n\nOptions: \n\t-abam\tThe A input file is in BAM format.  Output will be BAM as well. Replaces -a.\n\t\t- Requires BAM to be grouped or sorted by query.\n\n\t-ubam\tWrite uncompressed BAM output. Default writes compressed BAM.\n\n\t\tis to write output in BAM when using -abam.\n\n\t-bedpe\tWhen using BAM input (-abam), write output as BEDPE. The default\n\t\tis to write output in BAM when using -abam.\n\n\t-ed\tUse BAM total edit distance (NM tag) for BEDPE score.\n\t\t- Default for BEDPE is to use the minimum of\n\t\t  of the two mapping qualities for the pair.\n\t\t- When -ed is used the total edit distance\n\t\t  from the two mates is reported as the score.\n\n\t-f\tMinimum overlap required as fraction of A (e.g. 0.05).\n\t\tDefault is 1E-9 (effectively 1bp).\n\n\t-s\tRequire same strandedness when finding overlaps.\n\t\tDefault is to ignore stand.\n\t\tNot applicable with -type inspan or -type outspan.\n\n\t-S\tRequire different strandedness when finding overlaps.\n\t\tDefault is to ignore stand.\n\t\tNot applicable with -type inspan or -type outspan.\n\n\t-type \tApproach to reporting overlaps between BEDPE and BED.\n\n\t\teither\tReport overlaps if either end of A overlaps B.\n\t\t\t- Default.\n\t\tneither\tReport A if neither end of A overlaps B.\n\t\tboth\tReport overlaps if both ends of A overlap  B.\n\t\txor\tReport overlaps if one and only one end of A overlaps B.\n\t\tnotboth\tReport overlaps if neither end or one and only one \n\t\t\tend of A overlap B.  That is, xor + neither.\n\n\t\tispan\tReport overlaps between [end1, start2] of A and B.\n\t\t\t- Note: If chrom1 <> chrom2, entry is ignored.\n\n\t\tospan\tReport overlaps between [start1, end2] of A and B.\n\t\t\t- Note: If chrom1 <> chrom2, entry is ignored.\n\n\t\tnotispan\tReport A if ispan of A doesn't overlap B.\n\t\t\t\t- Note: If chrom1 <> chrom2, entry is ignored.\n\n\t\tnotospan\tReport A if ospan of A doesn't overlap B.\n\t\t\t\t- Note: If chrom1 <> chrom2, entry is ignored.\n\nRefer to the BEDTools manual for BEDPE format."
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dukegcb/bedtools
 inputs:
    aFile:
      type: File?
      inputBinding:
        position: 1
        prefix: -a
      doc: <bedpe>
    bFile:
      type: File
      inputBinding:
        position: 4
        prefix: -b
      doc: <bed/gff/vcf>
    abam:
      type: File?
      inputBinding:
        position: 1
        prefix: -abam
      doc: 'The A input file is in BAM format.  Output will be BAM as well. Replaces -a.
        - Requires BAM to be grouped or sorted by query.
        '
    ubam:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -ubam
      doc: |
        Write uncompressed BAM output. Default writes compressed BAM.
    bedpe:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -bedpe
      doc: |
        When using BAM input (-abam), write output as BEDPE. The default
        is to write output in BAM when using -abam.
    ed:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -ed
      doc: |
        Use BAM total edit distance (NM tag) for BEDPE score.
        - Default for BEDPE is to use the minimum of
        of the two mapping qualities for the pair.
        - When -ed is used the total edit distance
        from the two mates is reported as the score.
    f:
      type: int?
      inputBinding:
        position: 1
        prefix: -f
      doc: |
        Minimum overlap required as fraction of A (e.g. 0.05).
        Default is 1E-9 (effectively 1bp).
    s:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -s
      doc: |
        Require same strandedness when finding overlaps.
        Default is to ignore stand.
        Not applicable with -type inspan or -type outspan.
    S:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -S
      doc: |
        Require different strandedness when finding overlaps.
        Default is to ignore stand.
        Not applicable with -type inspan or -type outspan.
    type:
      type: string?
      inputBinding:
        position: 1
        prefix: -type
      doc: "\tApproach to reporting overlaps between BEDPE and BED.\neither\tReport overlaps if either end of A overlaps B.\n- Default.\nneither\tReport A if neither end of A overlaps B.\nboth\tReport overlaps if both ends of A overlap  B.\nxor\tReport overlaps if one and only one end of A overlaps B.\nnotboth\tReport overlaps if neither end or one and only one\nend of A overlap B.  That is, xor + neither.\nispan\tReport overlaps between [end1, start2] of A and B.\n- Note: If chrom1 <> chrom2, entry is ignored.\nospan\tReport overlaps between [start1, end2] of A and B.\n- Note: If chrom1 <> chrom2, entry is ignored.\nnotispan\tReport A if ispan of A doesn't overlap B.\n- Note: If chrom1 <> chrom2, entry is ignored.\nnotospan\tReport A if ospan of A doesn't overlap B.\n- Note: If chrom1 <> chrom2, entry is ignored.\nRefer to the BEDTools manual for BEDPE format.\n"
    outfile:
      type: string?
      doc: |
        Output filename return by this tool
 outputs:
    filtered:
      type: File
      outputBinding:
        glob: |
          ${return inputs.outfile || inputs.abam.basename.replace(/\.[^/.]+$/, '') + (inputs.bedpe ? '.bedpe' : '.bam')}
 baseCommand:
  - bedtools
  - pairtobed
 stdout: |
  ${return inputs.outfile || inputs.abam.basename.replace(/\.[^/.]+$/, '') + (inputs.bedpe ? '.bedpe' : '.bam')}

