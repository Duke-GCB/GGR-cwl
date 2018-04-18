 class: CommandLineTool
 cwlVersion: v1.0
 doc: "Tool:    bedtools slop (aka slopBed)\nVersion: v2.25.0\nSummary: Add requested base pairs of \"slop\" to each feature.\n\nUsage:   bedtools slop [OPTIONS] -i <bed/gff/vcf> -g <genome> [-b <int> or (-l and -r)]\n\nOptions: \n\t-b\tIncrease the BED/GFF/VCF entry -b base pairs in each direction.\n\t\t- (Integer) or (Float, e.g. 0.1) if used with -pct.\n\n\t-l\tThe number of base pairs to subtract from the start coordinate.\n\t\t- (Integer) or (Float, e.g. 0.1) if used with -pct.\n\n\t-r\tThe number of base pairs to add to the end coordinate.\n\t\t- (Integer) or (Float, e.g. 0.1) if used with -pct.\n\n\t-s\tDefine -l and -r based on strand.\n\t\tE.g. if used, -l 500 for a negative-stranded feature, \n\t\tit will add 500 bp downstream.  Default = false.\n\n\t-pct\tDefine -l and -r as a fraction of the feature's length.\n\t\tE.g. if used on a 1000bp feature, -l 0.50, \n\t\twill add 500 bp \"upstream\".  Default = false.\n\n\t-header\tPrint the header from the input file prior to results.\n\nNotes: \n\t(1)  Starts will be set to 0 if options would force it below 0.\n\t(2)  Ends will be set to the chromosome length if  requested slop would\n\tforce it above the max chrom length.\n\t(3)  The genome file should tab delimited and structured as follows:\n\n\t<chromName><TAB><chromSize>\n\n\tFor example, Human (hg19):\n\tchr1\t249250621\n\tchr2\t243199373\n\t...\n\tchr18_gl000207_random\t4262\n\nTips: \n\tOne can use the UCSC Genome Browser's MySQL database to extract\n\tchromosome sizes. For example, H. sapiens:\n\n\tmysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -e \\\n\t\"select chrom, size from hg19.chromInfo\"  > hg19.genome"
 requirements:
    InlineJavascriptRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: dukegcb/bedtools
 inputs:
    b:
      type: float?
      inputBinding:
        position: 1
        prefix: -b
      doc: |
        Increase the BED/GFF/VCF entry -b base pairs in each direction.
        - (Integer) or (Float, e.g. 0.1) if used with -pct.
    g:
      type: File
      inputBinding:
        position: 4
        prefix: -g
      doc: <genome>
    i:
      type: File
      inputBinding:
        position: 1
        prefix: -i
      doc: <bed/gff/vcf>
    l:
      type: float?
      inputBinding:
        position: 1
        prefix: -l
      doc: |
        The number of base pairs to subtract from the start coordinate.
        - (Integer) or (Float, e.g. 0.1) if used with -pct.
    pct:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -pct
      doc: |
        Define -l and -r as a fraction of the feature's length.
        E.g. if used on a 1000bp feature, -l 0.50,
        will add 500 bp "upstream".  Default = false.
    header:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -header
      doc: |
        Print the header from the input file prior to results.
    s:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -s
      doc: |
        Define -l and -r based on strand.
        E.g. if used, -l 500 for a negative-stranded feature,
        it will add 500 bp downstream.  Default = false.
    r:
      type: float?
      inputBinding:
        position: 1
        prefix: -r
      doc: |
        The number of base pairs to add to the end coordinate.
        - (Integer) or (Float, e.g. 0.1) if used with -pct.
    output_suffix:
      type: string
      default: .slop
 outputs:
    stdoutfile:
      type: File
      outputBinding:
        glob: $(inputs.i.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)
 baseCommand:
  - bedtools
  - slop
 stdout: $(inputs.i.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, "") + inputs.output_suffix)
