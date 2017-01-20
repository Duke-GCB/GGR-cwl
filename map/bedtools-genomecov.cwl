#!/usr/bin/env cwl-runner

cwlVersion: 'cwl:draft-3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/bedtools'

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement


inputs:
  - id: g
    type: File
    description: '<genome sizes>'
    inputBinding:
      position: 3
      prefix: '-g'
#  - id: i
#    type: File
#    description: '<bed/gff/vcf>'
#    inputBinding:
#      position: 2
#      prefix: '-i'
  - id: ibam
    type: File
    description: "\tThe input file is in BAM format.\nNote: BAM _must_ be sorted by position\n"
    inputBinding:
      position: 2
      prefix: '-ibam'
  - id: d
    type:
      - 'null'
      - boolean
    description: "\tReport the depth at each genome position (with one-based coordinates).\nDefault behavior is to report a histogram.\n"
    inputBinding:
      position: 1
      prefix: '-d'
  - id: dz
    type:
      - 'null'
      - boolean
    description: "\tReport the depth at each genome position (with zero-based coordinates).\nReports only non-zero positions.\nDefault behavior is to report a histogram.\n"
    inputBinding:
      position: 1
      prefix: '-dz'
  - id: bg
    type:
      - 'null'
      - boolean
    description: "\tReport depth in BedGraph format. For details, see:\ngenome.ucsc.edu/goldenPath/help/bedgraph.html\n"
    inputBinding:
      position: 1
      prefix: '-bg'
  - id: bga
    type:
      - 'null'
      - boolean
    description: "\tReport depth in BedGraph format, as above (-bg).\nHowever with this option, regions with zero\ncoverage are also reported. This allows one to\nquickly extract all regions of a genome with 0\ncoverage by applying: \"grep -w 0$\" to the output.\n"
    inputBinding:
      position: 1
      prefix: '-bga'
  - id: split
    type:
      - 'null'
      - boolean
    description: "\tTreat \"split\" BAM or BED12 entries as distinct BED intervals.\nwhen computing coverage.\nFor BAM files, this uses the CIGAR \"N\" and \"D\" operations\nto infer the blocks for computing coverage.\nFor BED12 files, this uses the BlockCount, BlockStarts, and BlockEnds\nfields (i.e., columns 10,11,12).\n"
    inputBinding:
      position: 1
      prefix: '-split'
  - id: strand
    type:
      - 'null'
      - string
    description: "\tCalculate coverage of intervals from a specific strand.\nWith BED files, requires at least 6 columns (strand is column 6).\n- (STRING): can be + or -\n"
    inputBinding:
      position: 1
      prefix: '-strand'
  - id: '5'
    type:
      - 'null'
      - boolean
    description: "\tCalculate coverage of 5\" positions (instead of entire interval).\n"
    inputBinding:
      position: 1
      prefix: '-5'
  - id: '3'
    type:
      - 'null'
      - boolean
    description: "\tCalculate coverage of 3\" positions (instead of entire interval).\n"
    inputBinding:
      position: 1
      prefix: '-3'
  - id: max
    type:
      - 'null'
      - int
    description: "\tCombine all positions with a depth >= max into\na single bin in the histogram. Irrelevant\nfor -d and -bedGraph\n- (INTEGER)\n"
    inputBinding:
      position: 1
      prefix: '-max'
  - id: scale
    type:
      - 'null'
      - float
    description: "\tScale the coverage by a constant factor.\nEach coverage value is multiplied by this factor before being reported.\nUseful for normalizing coverage by, e.g., reads per million (RPM).\n- Default is 1.0; i.e., unscaled.\n- (FLOAT)\n"
    inputBinding:
      position: 1
      prefix: '-scale'
  - id: trackline
    type:
      - 'null'
      - boolean
    description: >
      Adds a UCSC/Genome-Browser track line definition in the first line of the
      output.

      - See here for more details about track line definition:

      http://genome.ucsc.edu/goldenPath/help/bedgraph.html

      - NOTE: When adding a trackline definition, the output BedGraph can be
      easily

      uploaded to the Genome Browser as a custom track,

      BUT CAN NOT be converted into a BigWig file (w/o removing the first line).
    inputBinding:
      position: 1
      prefix: '-trackline'
  - id: trackopts
    type:
      - 'null'
      - string
    description: |
      Writes additional track line definition parameters in the first line.
      - Example:
      -trackopts 'name="My Track" visibility=2 color=255,30,30'
      Note the use of single-quotes if you have spaces in your parameters.
      - (TEXT)
    inputBinding:
      position: 1
      prefix: '-trackopts'
outputs:
  - id: '#output_bedfile'
    type: File
    outputBinding:
      glob: $(inputs.ibam.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + '.bdg')
stdout: $(inputs.ibam.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '') + '.bdg')
baseCommand:
  - bedtools
  - genomecov
description: "Tool:    bedtools genomecov (aka genomeCoverageBed)\nVersion: v2.25.0\nSummary: Compute the coverage of a feature file among a genome.\n\nUsage: bedtools genomecov [OPTIONS] -i <bed/gff/vcf> -g <genome>\n\nOptions: \n\t-ibam\t\tThe input file is in BAM format.\n\t\t\tNote: BAM _must_ be sorted by position\n\n\t-d\t\tReport the depth at each genome position (with one-based coordinates).\n\t\t\tDefault behavior is to report a histogram.\n\n\t-dz\t\tReport the depth at each genome position (with zero-based coordinates).\n\t\t\tReports only non-zero positions.\n\t\t\tDefault behavior is to report a histogram.\n\n\t-bg\t\tReport depth in BedGraph format. For details, see:\n\t\t\tgenome.ucsc.edu/goldenPath/help/bedgraph.html\n\n\t-bga\t\tReport depth in BedGraph format, as above (-bg).\n\t\t\tHowever with this option, regions with zero \n\t\t\tcoverage are also reported. This allows one to\n\t\t\tquickly extract all regions of a genome with 0 \n\t\t\tcoverage by applying: \"grep -w 0$\" to the output.\n\n\t-split\t\tTreat \"split\" BAM or BED12 entries as distinct BED intervals.\n\t\t\twhen computing coverage.\n\t\t\tFor BAM files, this uses the CIGAR \"N\" and \"D\" operations \n\t\t\tto infer the blocks for computing coverage.\n\t\t\tFor BED12 files, this uses the BlockCount, BlockStarts, and BlockEnds\n\t\t\tfields (i.e., columns 10,11,12).\n\n\t-strand\t\tCalculate coverage of intervals from a specific strand.\n\t\t\tWith BED files, requires at least 6 columns (strand is column 6). \n\t\t\t- (STRING): can be + or -\n\n\t-5\t\tCalculate coverage of 5\" positions (instead of entire interval).\n\n\t-3\t\tCalculate coverage of 3\" positions (instead of entire interval).\n\n\t-max\t\tCombine all positions with a depth >= max into\n\t\t\ta single bin in the histogram. Irrelevant\n\t\t\tfor -d and -bedGraph\n\t\t\t- (INTEGER)\n\n\t-scale\t\tScale the coverage by a constant factor.\n\t\t\tEach coverage value is multiplied by this factor before being reported.\n\t\t\tUseful for normalizing coverage by, e.g., reads per million (RPM).\n\t\t\t- Default is 1.0; i.e., unscaled.\n\t\t\t- (FLOAT)\n\n\t-trackline\tAdds a UCSC/Genome-Browser track line definition in the first line of the output.\n\t\t\t- See here for more details about track line definition:\n\t\t\t      http://genome.ucsc.edu/goldenPath/help/bedgraph.html\n\t\t\t- NOTE: When adding a trackline definition, the output BedGraph can be easily\n\t\t\t      uploaded to the Genome Browser as a custom track,\n\t\t\t      BUT CAN NOT be converted into a BigWig file (w/o removing the first line).\n\n\t-trackopts\tWrites additional track line definition parameters in the first line.\n\t\t\t- Example:\n\t\t\t   -trackopts 'name=\"My Track\" visibility=2 color=255,30,30'\n\t\t\t   Note the use of single-quotes if you have spaces in your parameters.\n\t\t\t- (TEXT)\n\nNotes: \n\t(1) The genome file should tab delimited and structured as follows:\n\t <chromName><TAB><chromSize>\n\n\tFor example, Human (hg19):\n\tchr1\t249250621\n\tchr2\t243199373\n\t...\n\tchr18_gl000207_random\t4262\n\n\t(2) The input BED (-i) file must be grouped by chromosome.\n\t A simple \"sort -k 1,1 <BED> > <BED>.sorted\" will suffice.\n\n\t(3) The input BAM (-ibam) file must be sorted by position.\n\t A \"samtools sort <BAM>\" should suffice.\n\nTips: \n\tOne can use the UCSC Genome Browser's MySQL database to extract\n\tchromosome sizes. For example, H. sapiens:\n\n\tmysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -e \\\n\t\"select chrom, size from hg19.chromInfo\" > hg19.genome"
# TODO: Currently only supports ibam (BAM files) as inputs, no <bed/gff/vcf>
