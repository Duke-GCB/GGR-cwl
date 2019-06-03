class: CommandLineTool
cwlVersion: v1.0

requirements:
   InlineJavascriptRequirement: {}
   ShellCommandRequirement: {}
hints:
   DockerRequirement:
     dockerPull: biocontainers/bowtie2:2.2.8
inputs:
   non-deterministic:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --non-deterministic
     doc: |
       seed rand. gen. arbitrarily instead of using read attributes
   qc-filter:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --qc-filter
     doc: '       filter out reads that are bad according to QSEQ filter
       '
   no-sq:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --no-sq
     doc: '           suppress @SQ header lines
       '
   version:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --version
     doc: '         print version information and quit
       '
   nthreads:
     type: int?
     inputBinding:
       position: 1
       prefix: --threads
     doc: |
       --threads <int> number of alignment threads to launch (1)
   mm:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --mm
     doc: '              use memory-mapped I/O for index; many bowtie can share'
   al:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --al
     doc: '<path>           write unpaired reads that aligned at least once to <path>
       '
   omit-sec-seq:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --omit-sec-seq
     doc: '    put ''*'' in SEQ and QUAL fields for secondary alignments.
       Performance:
       '
   seed:
     type: int?
     inputBinding:
       position: 1
       prefix: --seed
     doc: |
       <int>       seed for random number generator (0)
   rg:
     type: string?
     inputBinding:
       position: 1
       prefix: --rg
     doc: |
       <text>        add <text> ("lab:value") to @RG line of SAM header.
       Note: @RG line only printed when --rg-id is set.
   X:
     type: int?
     inputBinding:
       position: 1
       prefix: -X
     doc: |
       --maxins <int>  maximum fragment length (500)
   rg-id:
     type: string?
     inputBinding:
       position: 1
       prefix: --rg-id
     doc: |
       <text>     set read group id, reflected in @RG line and RG:Z: opt field
   met-stderr:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --met-stderr
     doc: '      send metrics to stderr (off)
       '
   score-min:
     type: string?
     inputBinding:
       position: 1
       prefix: --score-min
     doc: |
       <func> min acceptable alignment score w/r/t read length
       (G,20,8 for local, L,-0.6,-0.6 for end-to-end)
       Reporting:
       (default)          look for multiple alignments, report best, with MAPQ
       OR
   phred33:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --phred33
     doc: '         qualities are Phred+33 (default)
       '
   no-dovetail:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --no-dovetail
     doc: '     not concordant when mates extend past each other
       '
   no-discordant:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --no-discordant
     doc: '   suppress discordant alignments for paired reads
       '
   no-unal:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --no-unal
     doc: '         suppress SAM records for unaligned reads
       '
   ungz:
     type: string?
     inputBinding:
       position: 1
       prefix: --un-gz
       shellQuote: false
     doc: |
       <path>, to gzip compress output, or add '-bz2' to bzip2 compress output.)
   rdg:
     type: string?
     inputBinding:
       position: 1
       prefix: --rdg
       shellQuote: false
     doc: |
       <int>,<int>  read gap open, extend penalties (5,3)
   norc:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --norc
     doc: '            do not align reverse-complement version of read (off)
       '
   trim3:
     type: int?
     inputBinding:
       position: 1
       prefix: --trim3
     doc: |
       --trim3 <int>   trim <int> bases from 3'/right end of reads (0)
   un:
     type: string?
     inputBinding:
       position: 1
       prefix: --un
     doc: |
       <path>           write unpaired reads that didn't align to <path>
   trim5:
     type: int?
     inputBinding:
       position: 1
       prefix: --trim5
     doc: |
       --trim5 <int>   trim <int> bases from 5'/left end of reads (0)
   met-file:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --met-file
     doc: |
       <path>  send metrics to file at <path> (off)
   np:
     type: int?
     inputBinding:
       position: 1
       prefix: --np
     doc: |
       <int>         penalty for non-A/C/G/Ts in read/ref (1)
   rfg:
     type: int?
     inputBinding:
       position: 1
       prefix: --rfg
     doc: |
       <int>,<int>  reference gap open, extend penalties (5,3)
   reorder:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --reorder
     doc: '         force SAM output order to match order of input reads
       '
   t:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -t
     doc: |
       --time          print wall-clock time taken by search phases
   no-1mm-upfront:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --no-1mm-upfront
     doc: '  do not allow 1 mismatch alignments before attempting to
       scan for the optimal seeded alignments
       '
   ignore-quals:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --ignore-quals
     doc: '    treat all quality values as 30 on Phred scale (off)
       '
   fr:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --fr
     doc: |
       --rf/--ff     -1, -2 mates align fw/rev, rev/fw, fw/fw (--fr)
   no-mixed:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --no-mixed
     doc: '        suppress unpaired alignments for paired reads
       '
   D:
     type: int?
     inputBinding:
       position: 1
       prefix: -D
     doc: '<int>           give up extending after <int> failed extends in a row (15)
       '
   un-conc:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --un-conc
     doc: |
       <path>      write pairs that didn't align concordantly to <path>
   I:
     type: int?
     inputBinding:
       position: 1
       prefix: -I
     doc: |
       --minins <int>  minimum fragment length (0)
   int-quals:
     type: int?
     inputBinding:
       position: 1
       prefix: --int-quals
     doc: '       qualities encoded as space-delimited integers'
   no-contain:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --no-contain
     doc: '      not concordant when one mate alignment contains other
       '
   L:
     type: int?
     inputBinding:
       position: 1
       prefix: -L
     doc: |
       <int>           length of seed substrings; must be >3, <32 (22)
   N:
     type: int?
     inputBinding:
       position: 1
       prefix: -N
     doc: |
       <int>           max # mismatches in seed alignment; can be 0 or 1 (0)
   al-conc:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --al-conc
     doc: '<path>      write pairs that aligned concordantly at least once to <path>
       (Note: for --un, --al, --un-conc, or --al-conc, add ''-gz'' to the option name, e.g.
       '
   met:
     type: int?
     inputBinding:
       position: 1
       prefix: --met
     doc: |
       <int>        report internal counters & metrics every <int> secs (1)
   R:
     type: int?
     inputBinding:
       position: 1
       prefix: -R
     doc: '<int>           for reads w/ repetitive seeds, try <int> sets of seeds (2)
       Paired-end:
       '
   ma:
     type: int?
     inputBinding:
       position: 1
       prefix: --ma
     doc: "<int>         match bonus (0 for --end-to-end, 2 for --local) \n"
   gbar:
     type: int?
     inputBinding:
       position: 1
       prefix: --gbar
     doc: |
       <int>       disallow gaps within <int> nucs of read extremes (4)
   a:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -a
     doc: |
       --all           report all alignments; very slow, MAPQ not meaningful
       Effort:
   c:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -c
     doc: '                <m1>, <m2>, <r> are sequences themselves, not files
       '
   output_filename:
     type: string
     doc: name of the output file generated
   f:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -f
     doc: '                query input files are (multi-)FASTA .fa/.mfa
       '
   i:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -i
     doc: '<func>          interval between seed substrings w/r/t read len (S,1,1.15)
       '
   no-overlap:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --no-overlap
     doc: '      not concordant when mates overlap at all
       Output:
       '
   k:
     type: int?
     inputBinding:
       position: 1
       prefix: -k
     doc: |
       <int>           report up to <int> alns per read; MAPQ not meaningful
       OR
   no-head:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --no-head
     doc: '         suppress header lines, i.e. lines starting with @
       '
   quiet:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --quiet
     doc: '           print nothing to stderr except serious errors
       '
   q:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -q
     doc: '                query input files are FASTQ .fq/.fastq (default)
       '
   nofw:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --nofw
     doc: '            do not align forward (original) version of read (off)
       '
   skip:
     type: int?
     inputBinding:
       position: 1
       prefix: --skip
     doc: |
       --skip <int>    skip the first <int> reads/pairs in the input (none)
   r:
     type: boolean?
     inputBinding:
       position: 1
       prefix: -r
     doc: '                query input files are raw one-sequence-per-line
       '
   upto:
     type: int?
     inputBinding:
       position: 1
       prefix: --upto
     doc: |
       --upto <int>    stop after first <int> reads/pairs (no limit)
   mp:
     type: string?
     inputBinding:
       position: 1
       prefix: --mp
     doc: |
       <int>         max penalty for mismatch; lower qual = lower penalty (6)
   phred64:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --phred64
     doc: '         qualities are Phred+64
       '
   end-to-end:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --end-to-end
     doc: '      entire read must align; no clipping (on) [default]'
   local:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --local
     doc: '           local alignment; ends might be soft clipped (off)'
#   Presets:                 Same as:
#   For --end-to-end:
#   --very-fast            -D 5 -R 1 -N 0 -L 22 -i S,0,2.50
#   --fast                 -D 10 -R 2 -N 0 -L 22 -i S,0,2.50
#   --sensitive            -D 15 -R 2 -N 0 -L 22 -i S,1,1.15 (default)
#   --very-sensitive       -D 20 -R 3 -N 0 -L 20 -i S,1,0.50
#   For --local:
#   --very-fast-local      -D 5 -R 1 -N 0 -L 25 -i S,1,2.00
#   --fast-local           -D 10 -R 2 -N 0 -L 22 -i S,1,1.75
#   --sensitive-local      -D 15 -R 2 -N 0 -L 20 -i S,1,0.75 (default)
#   --very-sensitive-local -D 20 -R 3 -N 0 -L 20 -i S,1,0.50
#   Alignment:
   very-fast:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --very-fast
     doc: '      For --end-to-end: -D 5 -R 1 -N 0 -L 22 -i S,0,2.50; For --local: -D 5 -R 1 -N 0 -L 25 -i S,1,2.00'
   fast:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --fast
     doc: '      For --end-to-end: -D 10 -R 2 -N 0 -L 22 -i S,0,2.50; For --local: -D 10 -R 2 -N 0 -L 22 -i S,1,1.75'
   sensitive:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --sensitive
     doc: '      For --end-to-end: -D 15 -R 2 -N 0 -L 22 -i S,1,1.15; For --local: -D 15 -R 2 -N 0 -L 20 -i S,1,0.75 (default)'
   very-sensitive:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --very-sensitive
     doc: '      For --end-to-end: -D 20 -R 3 -N 0 -L 20 -i S,1,0.50; For --local: -D 20 -R 3 -N 0 -L 20 -i S,1,0.50'
   qseq:
     type: boolean?
     inputBinding:
       position: 1
       prefix: --qseq
     doc: '            query input files are in Illumina''s qseq format
       '
   n-ceil:
     type: string?
     inputBinding:
       position: 1
       prefix: --n-ceil
     doc: |
       <func>    func for max # non-A/C/G/Ts permitted in aln (L,0,0.15)
   dpad:
     type: int?
     inputBinding:
       position: 1
       prefix: --dpad
     doc: |
       <int>       include <int> extra ref chars on sides of DP table (15)
   genome_ref_first_index_file:
     type: File
     secondaryFiles:
     - ^^.2.bt2
     - ^^.3.bt2
     - ^^.4.bt2
     - ^^.rev.1.bt2
     - ^^.rev.2.bt2
     inputBinding:
       position: 2
       prefix: -x
       valueFrom: $(self.path.split('.').splice(0,self.path.split('.').length-2).join("."))
     doc: First file (extension .1.bt2) of the Bowtie2 index files generated for the reference genome (see http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#the-bowtie2-build-indexer)
   input_fastq_read1_file:
     type: File?
     inputBinding:
       position: 3
       prefix: '-1'
     doc: Query input FASTQ file read 1 (for paired-end samples).
   input_fastq_read2_file:
     type: File?
     inputBinding:
       position: 4
       prefix: '-2'
     doc: Query input FASTQ file read 2 (for paired-end samples).
   input_fastq_file:
     type: File?
     inputBinding:
       position: 3
       prefix: '-U'
     doc: Query input FASTQ file (for single-end samples).

outputs:
   outfile:
     type: File
     outputBinding:
       glob: $(inputs.output_filename + '.sam')
   output_bowtie_log:
     type: File
     outputBinding:
       glob: $(inputs.output_filename + '.bowtie2.log')
   output_unmapped_reads:
     type: File?
     outputBinding:
       glob: $(inputs.ungz)
baseCommand:
 - bowtie2
stdout: $(inputs.output_filename + '.sam')
stderr: $(inputs.output_filename + '.bowtie2.log')

doc: |
  Bowtie 2 version 2.2.8 by Ben Langmead (langmea@cs.jhu.edu, www.cs.jhu.edu/~langmea)
  Usage:
    bowtie2 [options]* -x <bt2-idx> {-1 <m1> -2 <m2> | -U <r>} [-S <sam>]

    <bt2-idx>  Index filename prefix (minus trailing .X.bt2).
               NOTE: Bowtie 1 and Bowtie 2 indexes are not compatible.
    <m1>       Files with #1 mates, paired with files in <m2>.
               Could be gzip'ed (extension: .gz) or bzip2'ed (extension: .bz2).
    <m2>       Files with #2 mates, paired with files in <m1>.
               Could be gzip'ed (extension: .gz) or bzip2'ed (extension: .bz2).
    <r>        Files with unpaired reads.
               Could be gzip'ed (extension: .gz) or bzip2'ed (extension: .bz2).
    <sam>      File for SAM output (default: stdout)

    <m1>, <m2>, <r> can be comma-separated lists (no whitespace) and can be
    specified many times.  E.g. '-U file1.fq,file2.fq -U file3.fq'.

  Options (defaults in parentheses):

   Input:
    -q                 query input files are FASTQ .fq/.fastq (default)
    --qseq             query input files are in Illumina's qseq format
    -f                 query input files are (multi-)FASTA .fa/.mfa
    -r                 query input files are raw one-sequence-per-line
    -c                 <m1>, <m2>, <r> are sequences themselves, not files
    -s/--skip <int>    skip the first <int> reads/pairs in the input (none)
    -u/--upto <int>    stop after first <int> reads/pairs (no limit)
    -5/--trim5 <int>   trim <int> bases from 5'/left end of reads (0)
    -3/--trim3 <int>   trim <int> bases from 3'/right end of reads (0)
    --phred33          qualities are Phred+33 (default)
    --phred64          qualities are Phred+64
    --int-quals        qualities encoded as space-delimited integers

   Presets:                 Same as:
    For --end-to-end:
     --very-fast            -D 5 -R 1 -N 0 -L 22 -i S,0,2.50
     --fast                 -D 10 -R 2 -N 0 -L 22 -i S,0,2.50
     --sensitive            -D 15 -R 2 -N 0 -L 22 -i S,1,1.15 (default)
     --very-sensitive       -D 20 -R 3 -N 0 -L 20 -i S,1,0.50

    For --local:
     --very-fast-local      -D 5 -R 1 -N 0 -L 25 -i S,1,2.00
     --fast-local           -D 10 -R 2 -N 0 -L 22 -i S,1,1.75
     --sensitive-local      -D 15 -R 2 -N 0 -L 20 -i S,1,0.75 (default)
     --very-sensitive-local -D 20 -R 3 -N 0 -L 20 -i S,1,0.50

   Alignment:
    -N <int>           max # mismatches in seed alignment; can be 0 or 1 (0)
    -L <int>           length of seed substrings; must be >3, <32 (22)
    -i <func>          interval between seed substrings w/r/t read len (S,1,1.15)
    --n-ceil <func>    func for max # non-A/C/G/Ts permitted in aln (L,0,0.15)
    --dpad <int>       include <int> extra ref chars on sides of DP table (15)
    --gbar <int>       disallow gaps within <int> nucs of read extremes (4)
    --ignore-quals     treat all quality values as 30 on Phred scale (off)
    --nofw             do not align forward (original) version of read (off)
    --norc             do not align reverse-complement version of read (off)
    --no-1mm-upfront   do not allow 1 mismatch alignments before attempting to
                       scan for the optimal seeded alignments
    --end-to-end       entire read must align; no clipping (on)
     OR
    --local            local alignment; ends might be soft clipped (off)

   Scoring:
    --ma <int>         match bonus (0 for --end-to-end, 2 for --local)
    --mp <int>         max penalty for mismatch; lower qual = lower penalty (6)
    --np <int>         penalty for non-A/C/G/Ts in read/ref (1)
    --rdg <int>,<int>  read gap open, extend penalties (5,3)
    --rfg <int>,<int>  reference gap open, extend penalties (5,3)
    --score-min <func> min acceptable alignment score w/r/t read length
                       (G,20,8 for local, L,-0.6,-0.6 for end-to-end)

   Reporting:
    (default)          look for multiple alignments, report best, with MAPQ
     OR
    -k <int>           report up to <int> alns per read; MAPQ not meaningful
     OR
    -a/--all           report all alignments; very slow, MAPQ not meaningful

   Effort:
    -D <int>           give up extending after <int> failed extends in a row (15)
    -R <int>           for reads w/ repetitive seeds, try <int> sets of seeds (2)

   Paired-end:
    -I/--minins <int>  minimum fragment length (0)
    -X/--maxins <int>  maximum fragment length (500)
    --fr/--rf/--ff     -1, -2 mates align fw/rev, rev/fw, fw/fw (--fr)
    --no-mixed         suppress unpaired alignments for paired reads
    --no-discordant    suppress discordant alignments for paired reads
    --no-dovetail      not concordant when mates extend past each other
    --no-contain       not concordant when one mate alignment contains other
    --no-overlap       not concordant when mates overlap at all

   Output:
    -t/--time          print wall-clock time taken by search phases
    --un <path>           write unpaired reads that didn't align to <path>
    --al <path>           write unpaired reads that aligned at least once to <path>
    --un-conc <path>      write pairs that didn't align concordantly to <path>
    --al-conc <path>      write pairs that aligned concordantly at least once to <path>
    (Note: for --un, --al, --un-conc, or --al-conc, add '-gz' to the option name, e.g.
    --ungz <path>, to gzip compress output, or add '-bz2' to bzip2 compress output.)
    --quiet            print nothing to stderr except serious errors
    --met-file <path>  send metrics to file at <path> (off)
    --met-stderr       send metrics to stderr (off)
    --met <int>        report internal counters & metrics every <int> secs (1)
    --no-unal          suppress SAM records for unaligned reads
    --no-head          suppress header lines, i.e. lines starting with @
    --no-sq            suppress @SQ header lines
    --rg-id <text>     set read group id, reflected in @RG line and RG:Z: opt field
    --rg <text>        add <text> ("lab:value") to @RG line of SAM header.
                       Note: @RG line only printed when --rg-id is set.
    --omit-sec-seq     put '*' in SEQ and QUAL fields for secondary alignments.

   Performance:
    -p/--threads <int> number of alignment threads to launch (1)
    --reorder          force SAM output order to match order of input reads
    --mm               use memory-mapped I/O for index; many 'bowtie's can share

   Other:
    --qc-filter        filter out reads that are bad according to QSEQ filter
    --seed <int>       seed for random number generator (0)
    --non-deterministic seed rand. gen. arbitrarily instead of using read attributes
    --version          print version information and quit
