#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0
doc: 'RNA-seq 03 mapping - reads: PE'
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
 - class: MultipleInputFeatureRequirement
inputs:
   input_fastq_read1_files:
     doc: Input fastq files
     type: File[]
   input_fastq_read2_files:
     doc: Input fastq paired-end read 2 files
     type: File[]
   sjdb_name:
     default: ggr.SJ.out.all.tab
     type: string
   genome_sizes_file:
     doc: Genome sizes tab-delimited file
     type: File
   sjdb_name:
     default: ggr.SJ.out.all.tab
     type: string
   STARgenomeDir:
     doc: STAR genome reference/indices files.
     type: Directory
   annotation_file:
     doc: GTF annotation file
     type: File
   genome_fasta_files:
     doc: STAR genome generate - Genome FASTA file with all the genome sequences in FASTA format
     type: File[]
   sjdbOverhang:
     doc: 'Length of the genomic sequence around the annotated junction to be used in constructing the splice junctions database. Ideally, this length should be equal to the ReadLength-1, where ReadLength is the length of the reads. '
     type: string
   nthreads:
     default: 1
     type: int
outputs:
   star_aligned_unsorted_file:
     doc: STAR mapped unsorted file.
     type: File[]
     outputSource: star_pass2/aligned
   star_aligned_sorted_file:
     doc: STAR mapped unsorted file.
     type: File[]
     outputSource: index_star_pass2_bam/indexed_file
   star1_stat_files:
     doc: STAR pass-1 stat files.
     type:
       items:
       - 'null'
       - items: File
         type: array
       type: array
     outputSource: star_pass1/mappingstats
   read_count_mapped_star1:
     doc: Read counts of the mapped BAM files after STAR pass1
     type: File[]
     outputSource: mapped_reads_count_star1/output
   star_1pass_sjdb:
     doc: SJDB from union of STAR 1st pass
     type: File
     outputSource: create_sjdb/sjdb_out
   generated_genome_files:
     doc: STAR generated genome files
     type: Directory?
     outputSource: generate_genome/indices
   percentage_uniq_reads_star1:
     doc: Percentage of uniq reads from preseq c_curve output
     type: File[]
     outputSource: percent_uniq_reads_star1/output
   pcr_bottleneck_coef_file:
     doc: PCR Bottleneck Coefficient
     type: File[]
     outputSource: execute_pcr_bottleneck_coef/pbc_file
   star2_readspergene_file:
     doc: STAR pass-2 reads per gene counts file.
     type: File[]?
     outputSource: star_pass2/readspergene
   transcriptome_star_aligned_file:
     doc: STAR mapped unsorted file.
     type: File[]
     outputSource: transcriptome_star_pass2/transcriptomesam
   read_count_mapped_star2:
     doc: Read counts of the mapped BAM files after STAR pass2
     type: File[]
     outputSource: mapped_reads_count_star2/output
   transcriptome_star_stat_files:
     doc: STAR pass-2 aligned to transcriptome stat files.
     type:
       items:
       - 'null'
       - items: File
         type: array
       type: array
     outputSource: transcriptome_star_pass2/mappingstats
   star2_stat_files:
     doc: STAR pass-2 stat files.
     type:
       items:
       - 'null'
       - items: File
         type: array
       type: array
     outputSource: star_pass2/mappingstats
   read_count_transcriptome_mapped_star2:
     doc: Read counts of the mapped to transcriptome BAM files with STAR pass2
     type: File[]
     outputSource: transcriptome_mapped_reads_count_star2/output
steps:
   basename:
     run: ../utils/basename.cwl
     scatter: file_path
     in:
       file_path:
         source: input_fastq_read1_files
         valueFrom: $(self.basename)
       sep:
         valueFrom: .fastq
         valueFrom: '[\.|_]R1'
     out:
     - basename
   zip_fastq_files:
     run: ../utils/zip_arrays.cwl
     in:
       reads2: input_fastq_read2_files
       reads1: input_fastq_read1_files
     out:
     - zipped_list
   star_pass1:
     run: ../../workflows/tools/STAR.cwl
     scatterMethod: dotproduct
     scatter:
     - readFilesIn
     - outFileNamePrefix
     in:
       genomeDir: STARgenomeDir
       outSAMattributes:
         valueFrom: All
       outFileNamePrefix:
         source: basename/basename
         valueFrom: $(self + ".star1.")
       outSAMtype:
         valueFrom: $(["BAM", "Unsorted"])
       runThreadN: nthreads
       readFilesIn:
         source: zip_fastq_files/zipped_list
       sjdbOverhang:
         source: sjdbOverhang
         valueFrom: $(parseInt(self))
     out:
     - aligned
     - mappingstats
   sort_star_pass1_bam:
     run: ../map/samtools-sort.cwl
     scatter: input_file
     in:
       nthreads: nthreads
       input_file: star_pass1/aligned
     out:
     - sorted_file
   mapped_reads_count_star1:
     run: ../map/star-log-read-count.cwl
     scatter: star_log
     in:
       star_log:
         source: star_pass1/mappingstats
     out:
     - output
   create_sjdb:
     in:
       sjdb_out_filename: sjdb_name
       sjdb_files:
         source: star_pass1/aligned
         valueFrom: |
           ${
             return self.map(function(x){
               return x.secondaryFiles.filter(function (i){
                 return i.basename.search(/SJ.out.tab$/)>0
               }).reduce(function(a,b){return a.concat(b)} )
             })
           }
     run: ../map/create-conservative-sjdb.cwl
     out:
     - sjdb_out
   generate_genome:
     run: ../../workflows/tools/STAR.cwl
     in:
       genomeDir: STARgenomeDir
       genomeFastaFiles: genome_fasta_files
       sjdbFileChrStartEnd:
         source: create_sjdb/sjdb_out
         valueFrom: ${return [self]}
       runMode:
         valueFrom: genomeGenerate
       runThreadN: nthreads
       sjdbGTFfile: annotation_file
       sjdbOverhang:
         source: sjdbOverhang
         valueFrom: $(parseInt(self))
     out:
     - indices
   star_pass2:
     run: ../../workflows/tools/STAR.cwl
     scatterMethod: dotproduct
     scatter:
     - readFilesIn
     - outFileNamePrefix
     in:
       genomeDir: generate_genome/indices
       outFilterIntronMotifs:
         valueFrom: RemoveNoncanonical
       outSAMattributes:
         valueFrom: All
       outFilterMultimapNmax:
         valueFrom: ${return 1}
       outFileNamePrefix:
         source: basename/basename
         valueFrom: $(self + ".star2.")
       outSAMtype:
         valueFrom: $(['BAM', 'Unsorted'])
       runThreadN: nthreads
       readFilesIn:
         source: zip_fastq_files/zipped_list
       quantMode:
         valueFrom: GeneCounts
       sjdbOverhang:
         source: sjdbOverhang
         valueFrom: $(parseInt(self))
     out:
     - aligned
     - mappingstats
     - readspergene
   transcriptome_star_pass2:
     run: ../../workflows/tools/STAR.cwl
     scatterMethod: dotproduct
     scatter:
     - readFilesIn
     - outFileNamePrefix
     in:
       readFilesIn:
         source: zip_fastq_files/zipped_list
       alignSJoverhangMin:
         valueFrom: ${return 8}
       genomeDir: generate_genome/indices
       outFilterType:
         valueFrom: BySJout
       alignSJDBoverhangMin:
         valueFrom: ${return 1}
       outFilterIntronMotifs:
         valueFrom: RemoveNoncanonical
       outSAMattributes:
         valueFrom: All
       outSAMunmapped:
         valueFrom: Within
       outFilterMultimapNmax:
         valueFrom: ${return 20}
       alignIntronMax:
         valueFrom: ${return 1000000}
       outFilterMismatchNoverReadLmax:
         valueFrom: ${return 0.04}
       outFilterMismatchNmax:
         valueFrom: ${return 999}
       alignIntronMin:
         valueFrom: ${return 20}
       runThreadN: nthreads
       alignMatesGapMax:
         valueFrom: ${return 1000000}
       sjdbScore:
         valueFrom: ${return 1}
       outFileNamePrefix:
         source: input_fastq_read1_files
         valueFrom: $(self.basename + ".transcriptome.star2.")
       quantMode:
         valueFrom: TranscriptomeSAM
       sjdbOverhang:
         source: sjdbOverhang
         valueFrom: $(parseInt(self))
     out:
     - transcriptomesam
     - mappingstats
   preseq-c-curve:
     run: ../map/preseq-c_curve.cwl
     scatterMethod: dotproduct
     scatter:
     - input_sorted_file
     - output_file_basename
     in:
       input_sorted_file: sort_star_pass1_bam/sorted_file
       output_file_basename: basename/basename
     out:
     - output_file
   index_star_pass2_bam:
     run: ../map/samtools-index.cwl
     scatter: input_file
     in:
       input_file: sort_star_pass2_bam/sorted_file
     out:
     - indexed_file
   sort_star_pass2_bam:
     run: ../map/samtools-sort.cwl
     scatter: input_file
     in:
       nthreads: nthreads
       input_file: star_pass2/aligned
     out:
     - sorted_file
   mapped_reads_count_star2:
     run: ../map/star-log-read-count.cwl
     scatter: star_log
     in:
       star_log:
         source: star_pass2/mappingstats
     out:
     - output
   transcriptome_mapped_reads_count_star2:
     run: ../map/star-log-read-count.cwl
     scatter: star_log
     in:
       star_log:  transcriptome_star_pass2/mappingstats
     out:
     - output
   percent_uniq_reads_star1:
     run: ../map/preseq-percent-uniq-reads.cwl
     scatter: preseq_c_curve_outfile
     in:
       preseq_c_curve_outfile: preseq-c-curve/output_file
     out:
     - output
   execute_pcr_bottleneck_coef:
     run: ../map/pcr-bottleneck-coef.cwl
     in:
       input_bam_files: sort_star_pass1_bam/sorted_file
       genome_sizes: genome_sizes_file
       input_output_filenames: basename/basename
     out:
     - pbc_file