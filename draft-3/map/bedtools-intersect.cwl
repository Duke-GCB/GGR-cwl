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
  - id: b
    type: File
    description: '<bed/gff/vcf/bam>'
    inputBinding:
      position: 4
      prefix: '-b'
  - id: a
    type: File
    description: 'Input <bed/gff/vcf/bam> file'
    inputBinding:
      position: 1
      prefix: '-a'
  - id: wa
    type:
      - 'null'
      - boolean
    description: |
      Write the original entry in A for each overlap.
    inputBinding:
      position: 1
      prefix: '-wa'
  - id: wb
    type:
      - 'null'
      - boolean
    description: |
      Write the original entry in B for each overlap.
      - Useful for knowing _what_ A overlaps. Restricted by -f and -r.
    inputBinding:
      position: 1
      prefix: '-wb'
  - id: loj
    type:
      - 'null'
      - boolean
    description: |
      Perform a "left outer join". That is, for each feature in A
      report each overlap with B.  If no overlaps are found,
      report a NULL feature for B.
    inputBinding:
      position: 1
      prefix: '-loj'
  - id: wo
    type:
      - 'null'
      - boolean
    description: |
      Write the original A and B entries plus the number of base
      pairs of overlap between the two features.
      - Overlaps restricted by -f and -r.
      Only A features with overlap are reported.
    inputBinding:
      position: 1
      prefix: '-wo'
  - id: wao
    type:
      - 'null'
      - boolean
    description: |
      Write the original A and B entries plus the number of base
      pairs of overlap between the two features.
      - Overlapping features restricted by -f and -r.
      However, A features w/o overlap are also reported
      with a NULL B feature and overlap = 0.
    inputBinding:
      position: 1
      prefix: '-wao'
  - id: u
    type:
      - 'null'
      - boolean
    description: |
      Write the original A entry _once_ if _any_ overlaps found in B.
      - In other words, just report the fact >=1 hit was found.
      - Overlaps restricted by -f and -r.
    inputBinding:
      position: 1
      prefix: '-u'
  - id: c
    type:
      - 'null'
      - boolean
    description: |
      For each entry in A, report the number of overlaps with B.
      - Reports 0 for A entries that have no overlap with B.
      - Overlaps restricted by -f and -r.
    inputBinding:
      position: 1
      prefix: '-c'
  - id: v
    type:
      - 'null'
      - boolean
    description: |
      Only report those entries in A that have _no overlaps_ with B.
      - Similar to "grep -v" (an homage).
    inputBinding:
      position: 1
      prefix: '-v'
  - id: ubam
    type:
      - 'null'
      - boolean
    description: |
      Write uncompressed BAM output. Default writes compressed BAM.
    inputBinding:
      position: 1
      prefix: '-ubam'
  - id: s
    type:
      - 'null'
      - boolean
    description: |
      Require same strandedness.  That is, only report hits in B
      that overlap A on the _same_ strand.
      - By default, overlaps are reported without respect to strand.
    inputBinding:
      position: 1
      prefix: '-s'
  - id: S
    type:
      - 'null'
      - boolean
    description: |
      Require different strandedness.  That is, only report hits in B
      that overlap A on the _opposite_ strand.
      - By default, overlaps are reported without respect to strand.
    inputBinding:
      position: 1
      prefix: '-S'
  - id: f
    type:
      - 'null'
      - float
    description: |
      Minimum overlap required as a fraction of A.
      - Default is 1E-9 (i.e., 1bp).
      - FLOAT (e.g. 0.50)
    inputBinding:
      position: 1
      prefix: '-f'
  - id: F
    type:
      - 'null'
      - float
    description: |
      Minimum overlap required as a fraction of B.
      - Default is 1E-9 (i.e., 1bp).
      - FLOAT (e.g. 0.50)
    inputBinding:
      position: 1
      prefix: '-F'
  - id: r
    type:
      - 'null'
      - boolean
    description: |
      Require that the fraction overlap be reciprocal for A AND B.
      - In other words, if -f is 0.90 and -r is used, this requires
      that B overlap 90 percent of A and A _also_ overlaps 90 percent of B.
    inputBinding:
      position: 1
      prefix: '-r'
  - id: e
    type:
      - 'null'
      - boolean
    description: |
      Require that the minimum fraction be satisfied for A OR B.
      - In other words, if -e is used with -f 0.90 and -F 0.10 this requires
      that either 90 percent of A is covered OR 10 percent of  B is covered.
      Without -e, both fractions would have to be satisfied.
    inputBinding:
      position: 1
      prefix: '-e'
  - id: split
    type:
      - 'null'
      - boolean
    description: |
      Treat "split" BAM or BED12 entries as distinct BED intervals.
    inputBinding:
      position: 1
      prefix: '-split'
  - id: g
    type:
      - 'null'
      - boolean
    description: |
      Provide a genome file to enforce consistent chromosome sort order
      across input files. Only applies when used with -sorted option.
    inputBinding:
      position: 1
      prefix: '-g'
  - id: nonamecheck
    type:
      - 'null'
      - boolean
    description: >
      For sorted data, don't throw an error if the file has different naming
      conventions

      for the same chromosome. ex. "chr1" vs "chr01".
    inputBinding:
      position: 1
      prefix: '-nonamecheck'
  - id: sorted
    type:
      - 'null'
      - boolean
    description: |
      Use the "chromsweep" algorithm for sorted (-k1,1 -k2,2n) input.
    inputBinding:
      position: 1
      prefix: '-sorted'
  - id: names
    type:
      - 'null'
      - boolean
    description: |
      When using multiple databases, provide an alias for each that
      will appear instead of a fileId when also printing the DB record.
    inputBinding:
      position: 1
      prefix: '-names'
  - id: filenames
    type:
      - 'null'
      - boolean
    description: |
      When using multiple databases, show each complete filename
      instead of a fileId when also printing the DB record.
    inputBinding:
      position: 1
      prefix: '-filenames'
  - id: sortout
    type:
      - 'null'
      - boolean
    description: |
      When using multiple databases, sort the output DB hits
      for each record.
    inputBinding:
      position: 1
      prefix: '-sortout'
  - id: bed
    type:
      - 'null'
      - boolean
    description: |
      If using BAM input, write output as BED.
    inputBinding:
      position: 1
      prefix: '-bed'
  - id: header
    type:
      - 'null'
      - boolean
    description: |
      Print the header from the A file prior to results.
    inputBinding:
      position: 1
      prefix: '-header'
  - id: nobuf
    type:
      - 'null'
      - boolean
    description: |
      Disable buffered output. Using this option will cause each line
      of output to be printed as it is generated, rather than saved
      in a buffer. This will make printing large output files
      noticeably slower, but can be useful in conjunction with
      other software tools and scripts that need to process one
      line of bedtools output at a time.
    inputBinding:
      position: 1
      prefix: '-nobuf'
  - id: iobuf
    type:
      - 'null'
      - int
    description: |
      Specify amount of memory to use for input buffer.
      Takes an integer argument. Optional suffixes K/M/G supported.
      Note: currently has no effect with compressed files.
    inputBinding:
      position: 1
      prefix: '-iobuf'
  - id: "#output_basename_file"
    type: string

outputs:
  - id: '#file_wo_blacklist_regions'
    type: File
    outputBinding:
      glob: $(inputs.output_basename_file + '.masked.bam')

stdout: $(inputs.output_basename_file + '.masked.bam')
baseCommand:
  - bedtools
  - intersect
description: "Tool:    bedtools intersect (aka intersectBed)\nVersion: v2.25.0\nSummary: Report overlaps between two feature files.\n\nUsage:   bedtools intersect [OPTIONS] -a <bed/gff/vcf/bam> -b <bed/gff/vcf/bam>\n\n\tNote: -b may be followed with multiple databases and/or \n\twildcard (*) character(s). \nOptions: \n\t-wa\tWrite the original entry in A for each overlap.\n\n\t-wb\tWrite the original entry in B for each overlap.\n\t\t- Useful for knowing _what_ A overlaps. Restricted by -f and -r.\n\n\t-loj\tPerform a \"left outer join\". That is, for each feature in A\n\t\treport each overlap with B.  If no overlaps are found, \n\t\treport a NULL feature for B.\n\n\t-wo\tWrite the original A and B entries plus the number of base\n\t\tpairs of overlap between the two features.\n\t\t- Overlaps restricted by -f and -r.\n\t\t  Only A features with overlap are reported.\n\n\t-wao\tWrite the original A and B entries plus the number of base\n\t\tpairs of overlap between the two features.\n\t\t- Overlapping features restricted by -f and -r.\n\t\t  However, A features w/o overlap are also reported\n\t\t  with a NULL B feature and overlap = 0.\n\n\t-u\tWrite the original A entry _once_ if _any_ overlaps found in B.\n\t\t- In other words, just report the fact >=1 hit was found.\n\t\t- Overlaps restricted by -f and -r.\n\n\t-c\tFor each entry in A, report the number of overlaps with B.\n\t\t- Reports 0 for A entries that have no overlap with B.\n\t\t- Overlaps restricted by -f and -r.\n\n\t-v\tOnly report those entries in A that have _no overlaps_ with B.\n\t\t- Similar to \"grep -v\" (an homage).\n\n\t-ubam\tWrite uncompressed BAM output. Default writes compressed BAM.\n\n\t-s\tRequire same strandedness.  That is, only report hits in B\n\t\tthat overlap A on the _same_ strand.\n\t\t- By default, overlaps are reported without respect to strand.\n\n\t-S\tRequire different strandedness.  That is, only report hits in B\n\t\tthat overlap A on the _opposite_ strand.\n\t\t- By default, overlaps are reported without respect to strand.\n\n\t-f\tMinimum overlap required as a fraction of A.\n\t\t- Default is 1E-9 (i.e., 1bp).\n\t\t- FLOAT (e.g. 0.50)\n\n\t-F\tMinimum overlap required as a fraction of B.\n\t\t- Default is 1E-9 (i.e., 1bp).\n\t\t- FLOAT (e.g. 0.50)\n\n\t-r\tRequire that the fraction overlap be reciprocal for A AND B.\n\t\t- In other words, if -f is 0.90 and -r is used, this requires\n\t\t  that B overlap 90 percent of A and A _also_ overlaps 90 percent of B.\n\n\t-e\tRequire that the minimum fraction be satisfied for A OR B.\n\t\t- In other words, if -e is used with -f 0.90 and -F 0.10 this requires\n\t\t  that either 90 percent of A is covered OR 10 percent of  B is covered.\n\t\t  Without -e, both fractions would have to be satisfied.\n\n\t-split\tTreat \"split\" BAM or BED12 entries as distinct BED intervals.\n\n\t-g\tProvide a genome file to enforce consistent chromosome sort order\n\t\tacross input files. Only applies when used with -sorted option.\n\n\t-nonamecheck\tFor sorted data, don't throw an error if the file has different naming conventions\n\t\t\tfor the same chromosome. ex. \"chr1\" vs \"chr01\".\n\n\t-sorted\tUse the \"chromsweep\" algorithm for sorted (-k1,1 -k2,2n) input.\n\n\t-names\tWhen using multiple databases, provide an alias for each that\n\t\twill appear instead of a fileId when also printing the DB record.\n\n\t-filenames\tWhen using multiple databases, show each complete filename\n\t\t\tinstead of a fileId when also printing the DB record.\n\n\t-sortout\tWhen using multiple databases, sort the output DB hits\n\t\t\tfor each record.\n\n\t-bed\tIf using BAM input, write output as BED.\n\n\t-header\tPrint the header from the A file prior to results.\n\n\t-nobuf\tDisable buffered output. Using this option will cause each line\n\t\tof output to be printed as it is generated, rather than saved\n\t\tin a buffer. This will make printing large output files \n\t\tnoticeably slower, but can be useful in conjunction with\n\t\tother software tools and scripts that need to process one\n\t\tline of bedtools output at a time.\n\n\t-iobuf\tSpecify amount of memory to use for input buffer.\n\t\tTakes an integer argument. Optional suffixes K/M/G supported.\n\t\tNote: currently has no effect with compressed files.\n\nNotes: \n\t(1) When a BAM file is used for the A file, the alignment is retained if overlaps exist,\n\tand exlcuded if an overlap cannot be found.  If multiple overlaps exist, they are not\n\treported, as we are only testing for one or more overlaps."

