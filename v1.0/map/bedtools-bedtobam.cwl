 class: CommandLineTool
 cwlVersion: v1.0
 doc: "Tool:    bedtools bedtobam (aka bedToBam)\nVersion: v2.25.0\nSummary: Converts feature records to BAM format.\n\nUsage:   bedtools bedtobam [OPTIONS] -i <bed/gff/vcf> -g <genome>\n\nOptions: \n\t-mapq\tSet the mappinq quality for the BAM records.\n\t\t(INT) Default: 255\n\n\t-bed12\tThe BED file is in BED12 format.  The BAM CIGAR\n\t\tstring will reflect BED \"blocks\".\n\n\t-ubam\tWrite uncompressed BAM output. Default writes compressed BAM.\n\nNotes: \n\t(1)  BED files must be at least BED4 to create BAM (needs name field)."
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dukegcb/bedtools
 inputs:
    i:
      type: File
      inputBinding:
        position: 3
        prefix: -i
      doc: Input <bed/gff/vcf> file to be converted to BAM format
    ubam:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -ubam
      doc: |
        Write uncompressed BAM output. Default writes compressed BAM.
    mapq:
      type: int?
      inputBinding:
        position: 1
        prefix: -mapq
      doc: |
        Set the mappinq quality for the BAM records.
        (INT) Default: 255
    bed12:
      type: string?
      inputBinding:
        position: 1
        prefix: -bed12
      doc: |
        The BED file is in BED12 format.  The BAM CIGAR
        string will reflect BED "blocks".
    g:
      type: File
      inputBinding:
        position: 4
        prefix: -g
      doc: Genome chromosome sizes file
 outputs:
    bam_file:
      type: File
      outputBinding:
        glob: $(inputs.i.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + '.bam')
 baseCommand:
  - bedtools
  - bedtobam
 stdout: $(inputs.i.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + '.bam')
