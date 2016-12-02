#!/usr/bin/env cwl-runner

# Mantainer: alejandro.barrera@duke.edu
# Partially auto generated with clihp (https://github.com/portah/clihp, developed by Andrey.Kartashov@cchmc.org)
# Developed for GGR project (https://github.com/Duke-GCB/GGR-cwl)
cwlVersion: 'cwl:draft-3'
class: CommandLineTool
hints:
  - class: DockerRequirement
    dockerPull: 'dukegcb/rsem:1.2.21'
requirements:
  - class: InlineJavascriptRequirement
inputs:

  - id: upstream_read_files
    type:
      - 'null'
      - {type: array, items: File}
    description: |
      Comma-separated list of files containing single-end reads or
      upstream reads for paired-end data. By default, these files are
      assumed to be in FASTQ format. If the --no-qualities option is
      specified, then FASTA format is expected.
    inputBinding:
      position: 2
      itemSeparator: ","

  - id: downstream_read_file
    type:
      - 'null'
      - {type: array, items: File}
    description: |
      Comma-separated list of files containing downstream reads which are
      paired with the upstream reads. By default, these files are assumed
      to be in FASTQ format. If the --no-qualities option is specified,
      then FASTA format is expected.
    inputBinding:
      position: 3
      itemSeparator: ","

  - id: sam
    type:
      - 'null'
      - File
    description: |
      SAM formatted input file. If "-" is specified for the filename,
      SAM input is instead assumed to come from standard input. RSEM
      requires all alignments of the same read group together. For
      paired-end reads, RSEM also requires the two mates of any alignment
      be adjacent. See Description section for how to make input file obey
      RSEM's requirements.
    inputBinding:
      position: 2
      prefix: "--sam"

  - id: bam
    type:
      - 'null'
      - File
    description: |
      BAM formatted input file. If "-" is specified for the filename,
      BAM input is instead assumed to come from standard input. RSEM
      requires all alignments of the same read group together. For
      paired-end reads, RSEM also requires the two mates of any alignment
      be adjacent. See Description section for how to make input file obey
      RSEM's requirements.
    inputBinding:
      position: 2
      prefix: "--bam"

  - id: reference_name
    type: string
    description: |
      The name of the reference used. The user must have run
      'rsem-prepare-reference' with this reference_name before running
      this program.
    inputBinding:
      position: 4
      valueFrom: $(inputs.reference_files[0].path.replace(/[^\\\/]*$/, "") + self)
  - id: reference_files
    type:
      type: array
      items: File
    description: |
      <reference_name>.seq, <reference_name>.transcripts.fa, ...
      The user must have run 'rsem-prepare-reference' with a reference_name
      before running this program.
  - id: sample_name
    type: string
    description: |
      The name of the sample analyzed. All output files are prefixed by
      this name (e.g., sample_name.genes.results)
    inputBinding:
      position: 5

  - id: paired-end
    type:
      - 'null'
      - boolean
    description: "Input reads are paired-end reads. (Default: off)"
    inputBinding:
      position: 1
      prefix: '--paired-end'
  - id: no-qualities
    type:
      - 'null'
      - boolean
    description: "Input reads do not contain quality scores. (Default: off)"
    inputBinding:
      position: 1
      prefix: '--no-qualities'
  - id: strand-specific
    type:
      - 'null'
      - boolean
    description: |
      The RNA-Seq protocol used to generate the reads is strand specific,
      i.e., all (upstream) reads are derived from the forward strand. This
      option is equivalent to --forward-prob=1.0. With this option set, if
      RSEM runs the Bowtie/Bowtie 2 aligner, the '--norc' Bowtie/Bowtie 2
      option will be used, which disables alignment to the reverse strand
      of transcripts. (Default: off)
    inputBinding:
      position: 1
      prefix: '--strand-specific'
  - id: bowtie2
    type:
      - 'null'
      - boolean
    description: |
      Use Bowtie 2 instead of Bowtie to align reads. Since currently RSEM
      does not handle indel, local and discordant alignments, the Bowtie2
      parameters are set in a way to avoid those alignments. In
      particular, we use options '--sensitive --dpad 0 --gbar 99999999
      --mp 1,1 --np 1 --score-min L,0,-0.1' by default. The last parameter
      of '--score-min', '-0.1', is the negative of maximum mismatch rate.
      This rate can be set by option '--bowtie2-mismatch-rate'. If reads
      are paired-end, we additionally use options '--no-mixed' and
      '--no-discordant'. (Default: off)
    inputBinding:
      position: 1
      prefix: '--bowtie2'
  - id: num-threads
    type:
      - 'null'
      - int
    description: |
      --num-threads <int>
      Number of threads to use. Both Bowtie/Bowtie2, expression estimation
      and 'samtools sort' will use this many threads. (Default: 1)
    inputBinding:
      position: 1
      prefix: '--num-threads'
  - id: no-bam-output
    type:
      - 'null'
      - boolean
    description: "Do not output any BAM file. (Default: off)"
    inputBinding:
      position: 1
      prefix: '--no-bam-output'
  - id: output-genome-bam
    type:
      - 'null'
      - boolean
    description: |
      --output-genome-bam
      Generate a BAM file, 'sample_name.genome.bam', with alignments
      mapped to genomic coordinates and annotated with their posterior
      probabilities. In addition, RSEM will call samtools (included in
      RSEM package) to sort and index the bam file.
      'sample_name.genome.sorted.bam' and
      'sample_name.genome.sorted.bam.bai' will be generated. (Default:
      off)
    inputBinding:
      position: 1
      prefix: '--output-genome-bam'
  - id: sampling-for-bam
    type:
      - 'null'
      - boolean
    description: |
      --sampling-for-bam
      When RSEM generates a BAM file, instead of outputing all alignments
      a read has with their posterior probabilities, one alignment is
      sampled according to the posterior probabilities. The sampling
      procedure includes the alignment to the "noise" transcript, which
      does not appear in the BAM file. Only the sampled alignment has a
      weight of 1. All other alignments have weight 0. If the "noise"
      transcript is sampled, all alignments appeared in the BAM file
      should have weight 0. (Default: off)
    inputBinding:
      position: 1
      prefix: '--sampling-for-bam'
  - id: seed
    type:
      - 'null'
      - int
    description: |
      <int>
      Set the seed for the random number generators used in calculating
      posterior mean estimates and credibility intervals. The seed must be
      a non-negative 32 bit interger. (Default: off)
    inputBinding:
      position: 1
      prefix: '--seed'
  - id: calc-pme
    type:
      - 'null'
      - boolean
    description: |
      --calc-pme
      Run RSEM's collapsed Gibbs sampler to calculate posterior mean
      estimates. (Default: off)
    inputBinding:
      position: 1
      prefix: '--calc-pme'
  - id: calc-ci
    type:
      - 'null'
      - boolean
    description: |
      --calc-ci
      Calculate 95% credibility intervals and posterior mean estimates.
      The credibility level can be changed by setting
      '--ci-credibility-level'. (Default: off)
    inputBinding:
      position: 1
      prefix: '--calc-ci'
  - id: quiet
    type:
      - 'null'
      - boolean
    description: |
      --quiet
      Suppress the output of logging information. (Default: off)
    inputBinding:
      position: 1
      prefix: '--quiet'

###################
# ADVANCE OPTIONS #
###################

  - id: sam-header-info
    type:
      - 'null'
      - File
    description: |
      <file>
      RSEM reads header information from input by default. If this option
      is on, header information is read from the specified file. For the
      format of the file, please see SAM official website. (Default: "")
    inputBinding:
      position: 1
      prefix: '--sam-header-info'
  - id: seed-length
    type:
      - 'null'
      - int
    description: |
      <int>
      Seed length used by the read aligner. Providing the correct value is
      important for RSEM. If RSEM runs Bowtie, it uses this value for
      Bowtie's seed length parameter. Any read with its or at least one of
      its mates' (for paired-end reads) length less than this value will
      be ignored. If the references are not added poly(A) tails, the
      minimum allowed value is 5, otherwise, the minimum allowed value is
      25. Note that this script will only check if the value >= 5 and give
      a warning message if the value < 25 but >= 5. (Default: 25)
    inputBinding:
      position: 1
      prefix: '--seed-length'
  - id: tag
    type:
      - 'null'
      - string
    description: |
      <string>
      The name of the optional field used in the SAM input for identifying
      a read with too many valid alignments. The field should have the
      format <tagName>:i:<value>, where a <value> bigger than 0 indicates
      a read with too many alignments. (Default: "")
    inputBinding:
      position: 1
      prefix: '--tag'
  - id: bowtie-path
    type:
      - 'null'
      - boolean
    description: |
      <path>
      The path to the Bowtie executables. (Default: the path to the Bowtie
      executables is assumed to be in the user's PATH environment
      variable)
    inputBinding:
      position: 1
      prefix: '--bowtie-path'
  - id: bowtie-n
    type:
      - 'null'
      - int
    description: |
      <int>
      (Bowtie parameter) max # of mismatches in the seed. (Range: 0-3,
      Default: 2)
    inputBinding:
      position: 1
      prefix: '--bowtie-n'
  - id: bowtie-e
    type:
      - 'null'
      - int
    description: |
      <int>
      (Bowtie parameter) max sum of mismatch quality scores across the
      alignment. (Default: 99999999)
    inputBinding:
      position: 1
      prefix: '--bowtie-e'
  - id: bowtie-m
    type:
      - 'null'
      - int
    description: |
      <int>
      (Bowtie parameter) suppress all alignments for a read if > <int>
      valid alignments exist. (Default: 200)
    inputBinding:
      position: 1
      prefix: '--bowtie-m'
  - id: bowtie-chunkmbs
    type:
      - 'null'
      - int
    description: |
      <int>
      (Bowtie parameter) memory allocated for best first alignment
      calculation (Default: 0 - use Bowtie's default)
    inputBinding:
      position: 1
      prefix: '--bowtie-chunkmbs'
  - id: phred33-quals
    type:
      - 'null'
      - boolean
    description: |
      Input quality scores are encoded as Phred+33. (Default: on)
    inputBinding:
      position: 1
      prefix: '--phred33-quals'
  - id: phred64-quals
    type:
      - 'null'
      - boolean
    description: |
      Input quality scores are encoded as Phred+64 (default for GA
      Pipeline ver. >= 1.3). (Default: off)
    inputBinding:
      position: 1
      prefix: '--phred64-quals'
  - id: solexa-quals
    type:
      - 'null'
      - boolean
    description: |
      Input quality scores are solexa encoded (from GA Pipeline ver. <
      1.3). (Default: off)
    inputBinding:
      position: 1
      prefix: '--solexa-quals'
  - id: bowtie2-path
    type:
      - 'null'
      - boolean
    description: |
      <path>
      (Bowtie 2 parameter) The path to the Bowtie 2 executables. (Default:
      the path to the Bowtie 2 executables is assumed to be in the user's
      PATH environment variable)
    inputBinding:
      position: 1
      prefix: '--bowtie2-path'
  - id: bowtie2-mismatch-rate
    type:
      - 'null'
      - float
    description: |
      <double>
      (Bowtie 2 parameter) The maximum mismatch rate allowed. (Default:
      0.1)
    inputBinding:
      position: 1
      prefix: '--bowtie2-mismatch-rate'
  - id: bowtie2-k
    type:
      - 'null'
      - int
    description: |
      <int>
      (Bowtie 2 parameter) Find up to <int> alignments per read. (Default:
      200)
    inputBinding:
      position: 1
      prefix: '--bowtie2-k'
  - id: bowtie2-sensitivity-level
    type:
      - 'null'
      - string
    description: |
      <string>
      (Bowtie 2 parameter) Set Bowtie 2's preset options in --end-to-end
      mode. This option controls how hard Bowtie 2 tries to find
      alignments. <string> must be one of "very_fast", "fast", "sensitive"
      and "very_sensitive". The four candidates correspond to Bowtie 2's
      "--very-fast", "--fast", "--sensitive" and "--very-sensitive"
      options. (Default: "sensitive" - use Bowtie 2's default)
    inputBinding:
      position: 1
      prefix: '--bowtie2-sensitivity-level'
  - id: forward-prob
    type:
      - 'null'
      - float
    description: |
      <double>
      Probability of generating a read from the forward strand of a
      transcript. Set to 1 for a strand-specific protocol where all
      (upstream) reads are derived from the forward strand, 0 for a
      strand-specific protocol where all (upstream) read are derived from
      the reverse strand, or 0.5 for a non-strand-specific protocol.
      (Default: 0.5)
    inputBinding:
      position: 1
      prefix: '--forward-prob'
  - id: fragment-length-min
    type:
      - 'null'
      - int
    description: |
      <int>
      Minimum read/insert length allowed. This is also the value for the
      Bowtie/Bowtie2 -I option. (Default: 1)
    inputBinding:
      position: 1
      prefix: '--fragment-length-min'
  - id: fragment-length-max
    type:
      - 'null'
      - int
    description: |
      <int>
      Maximum read/insert length allowed. This is also the value for the
      Bowtie/Bowtie 2 -X option. (Default: 1000)
    inputBinding:
      position: 1
      prefix: '--fragment-length-max'
  - id: fragment-length-mean
    type:
      - 'null'
      - float
    description: |
      <double>
      (single-end data only) The mean of the fragment length distribution,
      which is assumed to be a Gaussian. (Default: -1, which disables use
      of the fragment length distribution)
    inputBinding:
      position: 1
      prefix: '--fragment-length-mean'
  - id: fragment-length-sd
    type:
      - 'null'
      - float
    description: |
      <double>
      (single-end data only) The standard deviation of the fragment length
      distribution, which is assumed to be a Gaussian. (Default: 0, which
      assumes that all fragments are of the same length, given by the
      rounded value of --fragment-length-mean)
    inputBinding:
      position: 1
      prefix: '--fragment-length-sd'
  - id: estimate-rspd
    type:
      - 'null'
      - boolean
    description: |
      Set this option if you want to estimate the read start position
      distribution (RSPD) from data. Otherwise, RSEM will use a uniform
      RSPD. (Default: off)
    inputBinding:
      position: 1
      prefix: '--estimate-rspd'
  - id: num-rspd-bins
    type:
      - 'null'
      - int
    description: |
      <int>
      Number of bins in the RSPD. Only relevant when '--estimate-rspd' is
      specified. Use of the default setting is recommended. (Default: 20)
    inputBinding:
      position: 1
      prefix: '--num-rspd-bins'
  - id: gibbs-burnin
    type:
      - 'null'
      - int
    description: |
      <int>
      The number of burn-in rounds for RSEM's Gibbs sampler. Each round
      passes over the entire data set once. If RSEM can use multiple
      threads, multiple Gibbs samplers will start at the same time and all
      samplers share the same burn-in number. (Default: 200)
    inputBinding:
      position: 1
      prefix: '--gibbs-burnin'
  - id: gibbs-number-of-samples
    type:
      - 'null'
      - int
    description: |
      <int>
      The total number of count vectors RSEM will collect from its Gibbs
      samplers. (Default: 1000)
    inputBinding:
      position: 1
      prefix: '--gibbs-number-of-samples'
  - id: gibbs-sampling-gap
    type:
      - 'null'
      - int
    description: |
      <int>
      The number of rounds between two succinct count vectors RSEM
      collects. If the count vector after round N is collected, the count
      vector after round N + <int> will also be collected. (Default: 1)
    inputBinding:
      position: 1
      prefix: '--gibbs-sampling-gap'
  - id: ci-credibility-level
    type:
      - 'null'
      - float
    description: |
      <double>
      The credibility level for credibility intervals. (Default: 0.95)
    inputBinding:
      position: 1
      prefix: '--ci-credibility-level'
  - id: ci-memory
    type:
      - 'null'
      - int
    description: |
      <int>
      Maximum size (in memory, MB) of the auxiliary buffer used for
      computing credibility intervals (CI). Set it larger for a faster CI
      calculation. However, leaving 2 GB memory free for other usage is
      recommended. (Default: 1024)
    inputBinding:
      position: 1
      prefix: '--ci-memory'
  - id: ci-number-of-samples-per-count-vector
    type:
      - 'null'
      - int
    description: |
      <int>
      The number of read generating probability vectors sampled per
      sampled count vector. The crebility intervals are calculated by
      first sampling P(C | D) and then sampling P(Theta | C) for each
      sampled count vector. This option controls how many Theta vectors
      are sampled per sampled count vector. (Default: 50)
    inputBinding:
      position: 1
      prefix: '--ci-number-of-samples-per-count-vector'
  - id: samtools-sort-mem
    type:
      - 'null'
      - string
    description: |
      <string>
      Set the maximum memory per thread that can be used by 'samtools
      sort'. <string> represents the memory and accepts suffices 'K/M/G'.
      RSEM will pass <string> to the '-m' option of 'samtools sort'.
      Please note that the default used here is different from the default
      used by samtools. (Default: 1G)
    inputBinding:
      position: 1
      prefix: '--samtools-sort-mem'
  - id: keep-intermediate-files
    type:
      - 'null'
      - boolean
    description: |
      Keep temporary files generated by RSEM. RSEM creates a temporary
      directory, 'sample_name.temp', into which it puts all intermediate
      output files. If this directory already exists, RSEM overwrites all
      files generated by previous RSEM runs inside of it. By default,
      after RSEM finishes, the temporary directory is deleted. Set this
      option to prevent the deletion of this directory and the
      intermediate files inside of it. (Default: off)
    inputBinding:
      position: 1
      prefix: '--keep-intermediate-files'
  - id: time
    type:
      - 'null'
      - boolean
    description: |
      Output time consumed by each step of RSEM to 'sample_name.time'.
      (Default: off)
    inputBinding:
      position: 1
      prefix: '--time'
  - id: temporary-folder
    type:
      - 'null'
      - string
    description: |
      <string>
      Set where to put the temporary files generated by RSEM. If the
      folder specified does not exist, RSEM will try to create it.
      (Default: sample_name.temp)
    inputBinding:
      position: 1
      prefix: '--temporary-folder'

outputs:
  - id: isoforms
    type: File
    outputBinding:
      glob: $(inputs.sample_name + ".isoforms.results")
    description: |
      File containing isoform level expression estimates. The first line
      contains column names separated by the tab character. The format of
      each line in the rest of this file is:

      transcript_id gene_id length effective_length expected_count TPM
      FPKM IsoPct [posterior_mean_count
      posterior_standard_deviation_of_count pme_TPM pme_FPKM
      IsoPct_from_pme_TPM TPM_ci_lower_bound TPM_ci_upper_bound
      FPKM_ci_lower_bound FPKM_ci_upper_bound]

      Fields are separated by the tab character. Fields within "[]" are
      optional. They will not be presented if neither '--calc-pme' nor
      '--calc-ci' is set.

      'transcript_id' is the transcript name of this transcript. 'gene_id'
      is the gene name of the gene which this transcript belongs to
      (denote this gene as its parent gene). If no gene information is
      provided, 'gene_id' and 'transcript_id' are the same.

      'length' is this transcript's sequence length (poly(A) tail is not
      counted). 'effective_length' counts only the positions that can
      generate a valid fragment. If no poly(A) tail is added,
      'effective_length' is equal to transcript length - mean fragment
      length + 1. If one transcript's effective length is less than 1,
      this transcript's both effective length and abundance estimates are
      set to 0.

      'expected_count' is the sum of the posterior probability of each
      read comes from this transcript over all reads. Because 1) each read
      aligning to this transcript has a probability of being generated
      from background noise; 2) RSEM may filter some alignable low quality
      reads, the sum of expected counts for all transcript are generally
      less than the total number of reads aligned.

      'TPM' stands for Transcripts Per Million. It is a relative measure
      of transcript abundance. The sum of all transcripts' TPM is 1
      million. 'FPKM' stands for Fragments Per Kilobase of transcript per
      Million mapped reads. It is another relative measure of transcript
      abundance. If we define l_bar be the mean transcript length in a
      sample, which can be calculated as

      l_bar = \sum_i TPM_i / 10^6 * effective_length_i (i goes through
      every transcript),

      the following equation is hold:

      FPKM_i = 10^3 / l_bar * TPM_i.

      We can see that the sum of FPKM is not a constant across samples.

      'IsoPct' stands for isoform percentage. It is the percentage of this
      transcript's abandunce over its parent gene's abandunce. If its
      parent gene has only one isoform or the gene information is not
      provided, this field will be set to 100.

      'posterior_mean_count', 'pme_TPM', 'pme_FPKM' are posterior mean
      estimates calculated by RSEM's Gibbs sampler.
      'posterior_standard_deviation_of_count' is the posterior standard
      deviation of counts. 'IsoPct_from_pme_TPM' is the isoform percentage
      calculated from 'pme_TPM' values.

      'TPM_ci_lower_bound', 'TPM_ci_upper_bound', 'FPKM_ci_lower_bound'
      and 'FPKM_ci_upper_bound' are lower(l) and upper(u) bounds of 95%
      credibility intervals for TPM and FPKM values. The bounds are
      inclusive (i.e. [l, u]).
  - id: genes
    type: File
    outputBinding:
      glob: $(inputs.sample_name + ".genes.results")
    description: |
      File containing gene level expression estimates. The first line
      contains column names separated by the tab character. The format of
      each line in the rest of this file is:

      gene_id transcript_id(s) length effective_length expected_count TPM
      FPKM [posterior_mean_count posterior_standard_deviation_of_count
      pme_TPM pme_FPKM TPM_ci_lower_bound TPM_ci_upper_bound
      FPKM_ci_lower_bound FPKM_ci_upper_bound]

      Fields are separated by the tab character. Fields within "[]" are
      optional. They will not be presented if neither '--calc-pme' nor
      '--calc-ci' is set.

      'transcript_id(s)' is a comma-separated list of transcript_ids
      belonging to this gene. If no gene information is provided,
      'gene_id' and 'transcript_id(s)' are identical (the
      'transcript_id').

      A gene's 'length' and 'effective_length' are defined as the weighted
      average of its transcripts' lengths and effective lengths (weighted
      by 'IsoPct'). A gene's abundance estimates are just the sum of its
      transcripts' abundance estimates.
  - id: alleles
    type:
      - 'null'
      - File
    outputBinding:
      glob: $(inputs.sample_name + ".alleles.results")
    description: |
      Only generated when the RSEM references are built with
      allele-specific transcripts.

      This file contains allele level expression estimates for
      allele-specific expression calculation. The first line contains
      column names separated by the tab character. The format of each line
      in the rest of this file is:

      allele_id transcript_id gene_id length effective_length
      expected_count TPM FPKM AlleleIsoPct AlleleGenePct
      [posterior_mean_count posterior_standard_deviation_of_count pme_TPM
      pme_FPKM AlleleIsoPct_from_pme_TPM AlleleGenePct_from_pme_TPM
      TPM_ci_lower_bound TPM_ci_upper_bound FPKM_ci_lower_bound
      FPKM_ci_upper_bound]

      Fields are separated by the tab character. Fields within "[]" are
      optional. They will not be presented if neither '--calc-pme' nor
      '--calc-ci' is set.

      'allele_id' is the allele-specific name of this allele-specific
      transcript.

      'AlleleIsoPct' stands for allele-specific percentage on isoform
      level. It is the percentage of this allele-specific transcript's
      abundance over its parent transcript's abundance. If its parent
      transcript has only one allele variant form, this field will be set
      to 100.

      'AlleleGenePct' stands for allele-specific percentage on gene level.
      It is the percentage of this allele-specific transcript's abundance
      over its parent gene's abundance.

      'AlleleIsoPct_from_pme_TPM' and 'AlleleGenePct_from_pme_TPM' have
      similar meanings. They are calculated based on posterior mean
      estimates.

      Please note that if this file is present, the fields 'length' and
      'effective_length' in 'sample_name.isoforms.results' should be
      interpreted similarly as the corresponding definitions in
      'sample_name.genes.results'.
  - id: transcript_bam
    type:
      - 'null'
      - File
    outputBinding:
      glob: $(inputs.sample_name + ".transcript.bam")
    description: |
      BAM-formatted file of read
      alignments in transcript coordinates. The MAPQ field of each
      alignment is set to min(100, floor(-10 * log10(1.0 - w) + 0.5)),
      where w is the posterior probability of that alignment being the
      true mapping of a read. In addition, RSEM pads a new tag ZW:f:value,
      where value is a single precision floating number representing the
      posterior probability. Because this file contains all alignment
      lines produced by bowtie or user-specified aligners, it can also be
      used as a replacement of the aligner generated BAM/SAM file. For
      paired-end reads, if one mate has alignments but the other does not,
      this file marks the alignable mate as "unmappable" (flag bit 0x4)
      and appends an optional field "Z0:A:!".
  - id: transcript_sorted_bam
    type:
      - 'null'
      - File
    outputBinding:
      glob: $(inputs.sample_name + ".transcript.sorted.bam")
  - id: transcript_sorted_bam_bai
    type:
      - 'null'
      - File
    outputBinding:
      glob: $(inputs.sample_name + ".transcript.sorted.bam.bai")
  - id: rsem_time
    type:
      - 'null'
      - File
    outputBinding:
      glob: $(inputs.sample_name + ".time")
    description: |
      Only generated when --time is specified.

      It contains time (in seconds) consumed by aligning reads, estimating
      expression levels and calculating credibility intervals.

  - id: rsem_stat
    type:
      - 'null'
      - {type: array, items: File}
    outputBinding:
      glob: $(inputs.sample_name + ".stat/*")
    description: |
      This is a folder instead of a file. All model related statistics are
      stored in this folder. Use 'rsem-plot-model' can generate plots
      using this folder.

      'sample_name.stat/sample_name.cnt' contains alignment statistics.
      The format and meanings of each field are described in
      'cnt_file_description.txt' under RSEM directory.

      'sample_name.stat/sample_name.model' stores RNA-Seq model parameters
      learned from the data. The format and meanings of each filed of this
      file are described in 'model_file_description.txt' under RSEM
      directory.
baseCommand:
  - rsem-calculate-expression
description: |
    In its default mode, this program aligns input reads against a reference
    transcriptome with Bowtie and calculates expression values using the
    alignments. RSEM assumes the data are single-end reads with quality
    scores, unless the '--paired-end' or '--no-qualities' options are
    specified. Users may use an alternative aligner by specifying one of the
    --sam and --bam options, and providing an alignment file in the
    specified format. However, users should make sure that they align
    against the indices generated by 'rsem-prepare-reference' and the
    alignment file satisfies the requirements mentioned in ARGUMENTS
    section.

    One simple way to make the alignment file satisfying RSEM's requirements
    (assuming the aligner used put mates in a paired-end read adjacent) is
    to use 'convert-sam-for-rsem' script. This script only accept SAM format
    files as input. If a BAM format file is obtained, please use samtools to
    convert it to a SAM file first. For example, if '/ref/mouse_125' is the
    'reference_name' and the SAM file is named 'input.sam', you can run the
    following command:

      convert-sam-for-rsem /ref/mouse_125 input.sam -o input_for_rsem.sam

    For details, please refer to 'convert-sam-for-rsem's documentation page.

    The SAM/BAM format RSEM uses is v1.4. However, it is compatible with old
    SAM/BAM format. However, RSEM cannot recognize 0x100 in the FLAG field.
    In addition, RSEM requires SEQ and QUAL are not '*'.

    The user must run 'rsem-prepare-reference' with the appropriate
    reference before using this program.

    For single-end data, it is strongly recommended that the user provide
    the fragment length distribution parameters (--fragment-length-mean and
    --fragment-length-sd). For paired-end data, RSEM will automatically
    learn a fragment length distribution from the data.

    Please note that some of the default values for the Bowtie parameters
    are not the same as those defined for Bowtie itself.

    The temporary directory and all intermediate files will be removed when
    RSEM finishes unless '--keep-intermediate-files' is specified.

    With the '--calc-pme' option, posterior mean estimates will be
    calculated in addition to maximum likelihood estimates.

    With the '--calc-ci' option, 95% credibility intervals and posterior
    mean estimates will be calculated in addition to maximum likelihood
    estimates.
