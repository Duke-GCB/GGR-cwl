# Programs
trimmomatic_jar = "/data/reddylab/software/Trimmomatic-0.32/trimmomatic-0.32.jar"
picard_jar = "/data/reddylab/software/picard/dist/picard.jar"


class ReferenceDataset(object):
    def __init__(self, genome='hg38'):
        self.default_adapters = "/data/reddylab/projects/GGR/auxiliary/adapters/default_adapters.fasta"
        _genome = genome.lower()
        if _genome == 'hg38' or _genome == 'grch38':
            self.bowtie_genome_ref_first_index = "/data/reddylab/Reference_Data/Genomes/hg38/GCA_000001405.15_GRCh38_no_alt_analysis_set.1.ebwt"
            self.star_genome_dir = "/data/reddylab/Reference_Data/Genomes/hg38/STAR_genome_sjdbOverhang_49_novelSJDB"
            self.genome_sizes_file = "/data/reddylab/projects/GGR/auxiliary/hg38.sizes"
            self.encode_blacklist_bedfile = "/data/reddylab/Reference_Data/ENCODE/hg38.blacklist.bed"
            self.genome_effective_size = "hs"
        elif _genome == 'hg19' or _genome == 'grch37':
            self.bowtie_genome_ref_first_index = "/data/reddylab/Reference_Data/Genomes/hg19/hg19.1.ebwt"
            self.star_genome_dir = "/data/reddylab/Reference_Data/Genomes/hg19/STAR_genome_sjdbOverhang_50"
            self.genome_sizes_file = "/data/reddylab/Reference_Data/Genomes/hg19/hg19.chrom.sizes"
            self.encode_blacklist_bedfile = "/data/reddylab/Reference_Data/ENCODE/wgEncodeDacMapabilityConsensusExcludable.hg19.bed"
            self.genome_effective_size = "hs"
        elif _genome == 'mm10' or _genome == 'grcm38':
            self.bowtie_genome_ref_first_index = "/data/reddylab/Reference_Data/Genomes/mm10/bowtie/GRCm38.1.ebwt"
            self.star_genome_dir = "/data/reddylab/Reference_Data/Genomes/mm10/STAR_genome_sjdbOverhang_49_novelSJDB"
            self.genome_sizes_file = "/data/reddylab/Reference_Data/Genomes/GRCm38/GRCm38.sizes"
            self.encode_blacklist_bedfile = "/data/reddylab/Reference_Data/ENCODE/mm10.blacklist.bed"
            self.genome_effective_size = "mm"
        elif _genome == 'mm9' or _genome == 'ncbi37':
            self.bowtie_genome_ref_first_index = "/data/reddylab/Reference_Data/Genomes/mm9/bowtie/mm9.1.ebwt"
            self.star_genome_dir = "/data/reddylab/Reference_Data/Genomes/mm9/STAR_genome_sjdbOverhang_50_novelSJDB"
            self.genome_sizes_file = "/data/reddylab/Reference_Data/Genomes/mm9/mm9.chrom.sizes"
            self.encode_blacklist_bedfile = "/data/reddylab/Reference_Data/ENCODE/mm9.blacklist.bed"
            self.genome_effective_size = "mm"
        elif _genome == 'danrer10' or _genome == 'grcz10':
            self.bowtie_genome_ref_first_index = "/data/reddylab/Reference_Data/Genomes/danRer10/bowtie/danRer10.1.ebwt"
            self.star_genome_dir = "/data/reddylab/Reference_Data/Genomes/danRer10/STAR_genome_sjdbOverhang_50_novelSJDB"
            self.genome_sizes_file = "/data/reddylab/Reference_Data/Genomes/danRer10/danRer10.chrom.sizes"
            self.encode_blacklist_bedfile = None
            self.genome_effective_size = "1.04e9"
        else:
            raise Exception("Genome %s not recognized" % genome)
