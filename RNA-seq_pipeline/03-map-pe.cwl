#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "RNA-seq 03 mapping - reads: PE"
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  - id: "#input_fastq_read1_files"
    type: {type: array, items: File}
    description: "Input fastq paired-end read 1 files"
  - id: "#input_fastq_read2_files"
    type: {type: array, items: File}
    description: "Input fastq paired-end read 2 files"
  - id: "#sjdb_name"
    type: string
    default: "ggr.SJ.out.all.tab"
  - id: "#genomeDirFiles"
    type: {type: array, items: File}
    description: "STAR genome reference/indices files."
  - id: "#genome_sizes_file"
    type: File
    description: "Genome sizes tab-delimited file"
  - id: "#sjdbOverhang"
    type: string
    description: |
      Length of the genomic sequence around the annotated junction
      to be used in constructing the splice junctions database.
      Ideally, this length should be equal to the ReadLength-1,
      where ReadLength is the length of the reads.
  - id: "#nthreads"
    type: int
    default: 1
  - id: "#annotation_file"
    type: File
    description: "GTF annotation file"
  - id: "#genome_fasta_files"
    type:
      type: array
      items: File
    description: "STAR genome generate - Genome FASTA file with all the genome sequences in FASTA format"
outputs:
  - id: "#star_aligned_unsorted_file"
    source: "#star_pass2.aligned"
    description: "STAR mapped unsorted file."
    type: {type: array, items: File}
  - id: "#star_aligned_sorted_file"
    source: "#sort_star_pass2_bam.sorted_file"
    description: "STAR mapped unsorted file."
    type: {type: array, items: File}
  - id: "#star_aligned_sorted_index_file"
    source: "#index_star_pass2_bam.index_file"
    description: "STAR mapped unsorted file."
    type: {type: array, items: File}
  - id: "#star1_stat_files"
    source: "#star_pass1.mappingstats"
    description: "STAR pass-1 stat files."
    type: {type: array, items: ['null', {items: File, type: array}]}
  - id: "#read_count_mapped_star1"
    source: "#mapped_reads_count_star1.output"
    description: "Read counts of the mapped BAM files after STAR pass1"
    type: {type: array, items: File}
  - id: "#star_1pass_sjdb"
    source: "#create_sjdb.sjdb_out"
    description: "SJDB from union of STAR 1st pass"
    type: File
  - id: "#generated_genome_files"
    source: "#generate_genome.indices"
    description: "STAR generated genome files"
    type: {type: array, items: File}
  - id: "#pcr_bottleneck_coef_file"
    source: "#execute_pcr_bottleneck_coef.pbc_file"
    description: "PCR Bottleneck Coefficient"
    type: {type: array, items: File}
  - id: "#percentage_uniq_reads_star1"
    source: "#percent_uniq_reads_star1.output"
    description: "Percentage of uniq reads from preseq c_curve output"
    type: {type: array, items: File}
  - id: "#star2_stat_files"
    source: "#star_pass2.mappingstats"
    description: "STAR pass-2 stat files."
    type: {type: array, items: ['null', {items: File, type: array}]}
  - id: "#star2_readspergene_file"
    source: "#star_pass2.readspergene"
    description: "STAR pass-2 reads per gene counts file."
    type: ['null', {type: array, items: File}]
  - id: "#read_count_mapped_star2"
    source: "#mapped_reads_count_star2.output"
    description: "Read counts of the mapped BAM files after STAR pass2"
    type: {type: array, items: File}
  - id: "#transcriptome_star_aligned_file"
    source: "#transcriptome_star_pass2.transcriptomesam"
    description: "STAR mapped unsorted file."
    type: {type: array, items: File}
#  - id: "#transcriptome_star_aligned_sorted_index_file"
#    source: "#index_transcriptome_star_pass2_bam.index_file"
#    description: "STAR mapped unsorted file."
#    type: {type: array, items: File}
  - id: "#transcriptome_star_stat_files"
    source: "#transcriptome_star_pass2.mappingstats"
    description: "STAR pass-2 aligned to transcriptome stat files."
    type: {type: array, items: ['null', {items: File, type: array}]}
  - id: "#read_count_transcriptome_mapped_star2"
    source: "#transcriptome_mapped_reads_count_star2.output"
    description: "Read counts of the mapped to transcriptome BAM files with STAR pass2"
    type: {type: array, items: File}
steps:
  - id: "#basename"
    run: {$import: "../utils/basename.cwl" }
    scatter: "#basename.file_path"
    inputs:
      - id: "#basename.file_path"
        source: "#input_fastq_read1_files"
        valueFrom: $(self.path)
      - id: "#sep"
        valueFrom: '[\.|_]R1'
    outputs:
      - id: "#basename.basename"
  - id: "#zip_fastq_files"
    run: {$import: "../utils/zip_arrays.cwl"}
    inputs:
      - {id: "#zip_fastq_files.reads1", source: "#input_fastq_read1_files"}
      - {id: "#zip_fastq_files.reads2", source: "#input_fastq_read2_files"}
    outputs:
      - id: "#zip_fastq_files.zipped_list"
  - id: "#star_pass1"
    run: {$import: "../workflows/tools/STAR.cwl" }
    scatter:
      - "#star_pass1.readFilesIn"
      - "#star_pass1.outFileNamePrefix"
    scatterMethod: dotproduct
    inputs:
      - id: "#star_pass1.readFilesIn"
        source: "#zip_fastq_files.zipped_list"
      - { id: "#star_pass1.sjdbOverhang", source: "#sjdbOverhang", valueFrom: $(parseInt(self))}
      - { id: "#star_pass1.genomeDir", source: "#genomeDirFiles" }
      - { id: "#star_pass1.outSAMattributes", valueFrom: "All" }
      - { id: "#star_pass1.runThreadN", source: "#nthreads"}
      - id: "#star_pass1.outFileNamePrefix"
        source: "#basename.basename"
        valueFrom: $(self + ".star1.")
#      - { id: "#star_pass1.genomeLoad", valueFrom: "LoadAndKeep" }
#      - { id: "#star_pass1.limitBAMsortRAM", valueFrom: $(300)}
      - id: "#star_pass1.outSAMtype"
        valueFrom: |
          $(["BAM", "Unsorted"])
    outputs:
      - id: "#star_pass1.aligned"
      - id: "#star_pass1.mappingstats"
  - id: "#sort_star_pass1_bam"
    run: {$import: "../map/samtools-sort.cwl"}
    scatter: "#sort_star_pass1_bam.input_file"
    inputs:
      - {id: "#sort_star_pass1_bam.input_file", source: "#star_pass1.aligned"}
      - {id: "#sort_star_pass1_bam.nthreads", source: "#nthreads"}
    outputs:
      - id: "#sort_star_pass1_bam.sorted_file"
  - id: "#mapped_reads_count_star1"
    run: {$import: "../map/star-log-read-count.cwl"}
    scatter: "#mapped_reads_count_star1.star_log"
    inputs:
      - id: "#mapped_reads_count_star1.star_log"
        source: "#star_pass1.mappingstats"
        valueFrom: $(self[0])
    outputs:
      - id: "#mapped_reads_count_star1.output"
  - id: "#create_sjdb"
    run: {$import: "../map/create-conservative-sjdb.cwl"}
    inputs:
#      - {id: "#create_sjdb.sjdb_files", source: "#sj"}
      - id: "#create_sjdb.sjdb_files"
        source: "#star_pass1.mappingstats"
        valueFrom: $(self.map(function(e){return e[1]}))
      - id: "#create_sjdb.sjdb_out_filename"
        source: "#sjdb_name"
    outputs:
      - id: "#create_sjdb.sjdb_out"
  - id: "#generate_genome"
    run: {$import: "../workflows/tools/STAR.cwl" }
    inputs:
      - { id: "#generate_genome.runMode", valueFrom: "genomeGenerate"}
      - { id: "#generate_genome.runThreadN", source: "#nthreads"}
      - { id: "#generate_genome.sjdbGTFfile", source: "#annotation_file"}
      - { id: "#generate_genome.genomeFastaFiles", source: "#genome_fasta_files"}
      - { id: "#generate_genome.sjdbOverhang", source: "#sjdbOverhang", valueFrom: $(parseInt(self))}
      - { id: "#generate_genome.genomeDir", valueFrom: "not_used" }
      - id: "#generate_genome.sjdbFileChrStartEnd"
        source: "#create_sjdb.sjdb_out"
        valueFrom: ${return [self]}
    outputs:
      - id: "#generate_genome.indices"
  - id: "#star_pass2"
    run: {$import: "../workflows/tools/STAR.cwl" }
    scatter:
      - "#star_pass2.readFilesIn"
      - "#star_pass2.outFileNamePrefix"
    scatterMethod: dotproduct
    inputs:
      - { id: "#star_pass2.quantMode", valueFrom: "GeneCounts" }
      - id: "#star_pass2.readFilesIn"
        source: "#zip_fastq_files.zipped_list"
      - { id: "#star_pass2.sjdbOverhang", source: "#sjdbOverhang", valueFrom: $(parseInt(self))}
      - { id: "#star_pass2.genomeDir", source: "#generate_genome.indices" } #TODO: This is my solution for the current challange that STAR presents, given that it needs a folder here...
      - { id: "#star_pass2.outSAMattributes", valueFrom: "All" }
      - { id: "#star_pass2.outFilterMultimapNmax", valueFrom: $(1) }
      - { id: "#star_pass2.outFilterIntronMotifs", valueFrom: "RemoveNoncanonical" }
      - { id: "#star_pass2.runThreadN", source: "#nthreads"}
      - id: "#star_pass2.outFileNamePrefix"
        source: "#basename.basename"
        valueFrom: $(self + ".star2.")
#      - { id: "#star_pass2.genomeLoad", valueFrom: "LoadAndKeep" }
#      - { id: "#star_pass2.limitBAMsortRAM", valueFrom: $(300)}
      - id: "#star_pass2.outSAMtype"
        valueFrom: $(['BAM', 'Unsorted'])
    outputs:
      - id: "#star_pass2.aligned"
      - id: "#star_pass2.mappingstats"
      - id: "#star_pass2.readspergene"
  - id: "#sort_star_pass2_bam"
    run: {$import: "../map/samtools-sort.cwl"}
    scatter: "#sort_star_pass2_bam.input_file"
    inputs:
      - {id: "#sort_star_pass2_bam.input_file", source: "#star_pass2.aligned"}
      - {id: "#sort_star_pass2_bam.nthreads", source: "#nthreads"}
    outputs:
      - id: "#sort_star_pass2_bam.sorted_file"
  - id: "#index_star_pass2_bam"
    run: {$import: "../map/samtools-index.cwl"}
    scatter:
      - "#index_star_pass2_bam.input_file"
    inputs:
      - { id: "#index_star_pass2_bam.input_file", source: "#sort_star_pass2_bam.sorted_file" }
    outputs:
      - id: "#index_star_pass2_bam.index_file"
  - id: "#mapped_reads_count_star2"
    run: {$import: "../map/star-log-read-count.cwl"}
    scatter: "#mapped_reads_count_star2.star_log"
    inputs:
      - id: "#mapped_reads_count_star2.star_log"
        source: "#star_pass2.mappingstats"
        valueFrom: $(self[0])
    outputs:
      - id: "#mapped_reads_count_star2.output"
  - id: "#preseq-c-curve"
    run: {$import: "../map/preseq-c_curve.cwl"}
    scatter:
      - "#preseq-c-curve.input_sorted_file"
      - "#preseq-c-curve.output_file_basename"
    scatterMethod: dotproduct
    inputs:
      - {id: "#preseq-c-curve.input_sorted_file", source: "#sort_star_pass1_bam.sorted_file"}
      - {id: "#preseq-c-curve.output_file_basename", source: "#basename.basename"}
    outputs:
      - id: "#preseq-c-curve.output_file"
  - id: "#execute_pcr_bottleneck_coef"
    run: {$import: "../map/pcr-bottleneck-coef.cwl"}
    inputs:
      - {id: "#execute_pcr_bottleneck_coef.input_bam_files", source: "#sort_star_pass1_bam.sorted_file"}
      - {id: "#execute_pcr_bottleneck_coef.genome_sizes", source: "#genome_sizes_file"}
      - {id: "#execute_pcr_bottleneck_coef.input_output_filenames", source: "#basename.basename"}
    outputs:
      - id: "#execute_pcr_bottleneck_coef.pbc_file"
  - id: "#percent_uniq_reads_star1"
    run: {$import: "../map/preseq-percent-uniq-reads.cwl"}
    scatter: "#percent_uniq_reads_star1.preseq_c_curve_outfile"
    inputs:
      - {id: "#percent_uniq_reads_star1.preseq_c_curve_outfile", source: "#preseq-c-curve.output_file"}
    outputs:
      - id: "#percent_uniq_reads_star1.output"
  - id: "#transcriptome_star_pass2"
    run: {$import: "../workflows/tools/STAR.cwl" }
    scatter:
      - "#transcriptome_star_pass2.readFilesIn"
      - "#transcriptome_star_pass2.outFileNamePrefix"
    scatterMethod: dotproduct
    inputs:
      - { id: "#transcriptome_star_pass2.quantMode", valueFrom: "TranscriptomeSAM" }
      - id: "#transcriptome_star_pass2.readFilesIn"
        source: "#zip_fastq_files.zipped_list"
      - { id: "#transcriptome_star_pass2.sjdbOverhang", source: "#sjdbOverhang", valueFrom: $(parseInt(self))}
      - { id: "#transcriptome_star_pass2.genomeDir", source: "#generate_genome.indices" } #TODO: See previous TODO
      - { id: "#transcriptome_star_pass2.outSAMattributes", valueFrom: "NH HI AS NM MD" }
      - { id: "#transcriptome_star_pass2.outSAMunmapped", valueFrom: "Within" }
      - { id: "#transcriptome_star_pass2.outFilterType", valueFrom: "BySJout" }
      - { id: "#transcriptome_star_pass2.outFilterIntronMotifs", valueFrom: "RemoveNoncanonical" }
      - { id: "#transcriptome_star_pass2.outFilterMultimapNmax", valueFrom: $(20) }
      - { id: "#transcriptome_star_pass2.outFilterMismatchNmax", valueFrom: $(999) }
      - { id: "#transcriptome_star_pass2.outFilterMismatchNoverReadLmax", valueFrom: $(0.04) }
      - { id: "#transcriptome_star_pass2.alignIntronMin", valueFrom: $(20)}
      - { id: "#transcriptome_star_pass2.alignIntronMax", valueFrom: $(1000000)}
      - { id: "#transcriptome_star_pass2.alignMatesGapMax", valueFrom: $(1000000)}
      - { id: "#transcriptome_star_pass2.alignSJoverhangMin", valueFrom: $(8)}
      - { id: "#transcriptome_star_pass2.alignSJDBoverhangMin", valueFrom: $(1)}
      - { id: "#transcriptome_star_pass2.sjdbScore", valueFrom: $(1)}
      - { id: "#transcriptome_star_pass2.runThreadN", source: "#nthreads"}
      - id: "#transcriptome_star_pass2.outFileNamePrefix"
        source: "#basename.basename"
        valueFrom: $(self + ".transcriptome.star2.")
#      - id: "#transcriptome_star_pass2.outSAMtype"
#        valueFrom:  $(['BAM', 'Unsorted'])
    outputs:
      - id: "#transcriptome_star_pass2.transcriptomesam"
      - id: "#transcriptome_star_pass2.mappingstats"
#  - id: "#sort_transcriptome_star_pass2_bam"
#    run: {$import: "../map/samtools-sort.cwl"}
#    scatter: "#sort_transcriptome_star_pass2_bam.input_file"
#    inputs:
#      - {id: "#sort_transcriptome_star_pass2_bam.input_file", source: "#transcriptome_star_pass2.transcriptomesam"}
#      - {id: "#sort_transcriptome_star_pass2_bam.nthreads", source: "#nthreads"}
#    outputs:
#      - id: "#sort_transcriptome_star_pass2_bam.sorted_file"
#
#  - id: "#index_transcriptome_star_pass2_bam"
#    run: {$import: "../map/samtools-index.cwl"}
#    scatter:
#      - "#index_transcriptome_star_pass2_bam.input_file"
#    inputs:
#      - { id: "#index_transcriptome_star_pass2_bam.input_file", source: "#sort_transcriptome_star_pass2_bam.sorted_file" }
#    outputs:
#      - id: "#index_transcriptome_star_pass2_bam.index_file"
  - id: "#transcriptome_mapped_reads_count_star2"
    run: {$import: "../map/star-log-read-count.cwl"}
    scatter: "#transcriptome_mapped_reads_count_star2.star_log"
    inputs:
      - id: "#transcriptome_mapped_reads_count_star2.star_log"
        source: "#transcriptome_star_pass2.mappingstats"
        valueFrom: $(self[0])
    outputs:
      - id: "#transcriptome_mapped_reads_count_star2.output"