import argparse
import os
import sys
import textwrap
from collections import defaultdict
from xlrd import XLRDError
import pandas as pd
from jinja2 import Environment, FileSystemLoader

import consts

encoding = sys.getfilesystemencoding()
EXEC_DIR = os.path.dirname(unicode(__file__, encoding))


def save_or_print_json(json_str, outdir, json_name):
    if outdir:
        with open("%s/%s.json" % (outdir, json_name), 'w') as cout:
            cout.writelines(json_str)
    else:
        print "#%s.json" % json_name
        print json_str


def is_false(v):
    return str(v).lower() in ("", "no", "false", "f", "0")


class MetadataParser(object):
    def __init__(self, args):
        self.experiment_type = args.data_type
        self.nthreads = args.nthreads
        self.mem = args.mem
        self.file_path = args.meta_file
        self.records = self.load_file()
        self.separate_jsons = args.separate_jsons
        self.default_adapters = args.default_adapters
        self.genome_effective_size = args.genome_effective_size
        self.genome_ref_first_index = args.genome_ref_first_index
        self.genome_sizes_file = args.genome_sizes_file
        self.genome_fasta_files = args.genome_fasta_files
        self.annotation_file = args.annotation_file
        self.rsem_dir = args.rsem_dir
        self.encode_blacklist_bedfile = args.encode_blacklist_bedfile
        self.trimmomatic_jar = args.trimmomatic_jar
        self.picard_jar = args.picard_jar
        self.as_narrowPeak = args.as_narrowPeak
        self.as_broadPeak = args.as_broadPeak
        self.star_genome_dir = args.star_genome_dir
        self.bamtools_forward_filter = args.bamtools_forward_filter
        self.bamtools_reverse_filter = args.bamtools_reverse_filter
        self.preserve_arguments = args.preserve_arguments
        self.read_length = args.read_length

        # To allow certain configuration files to be overriden, this is needed
        self.purge_undef_args()

    def purge_undef_args(self):
        for empty_key in [k for k, v in self.__dict__.iteritems() if v is None]:
            del self.__dict__[empty_key]

    def render_json(self, wf_conf, samples_list, data_dir, template_name):
        pass

    def parse_metadata(self, data_dir):
        pass

    def load_file(self):
        try:
            rows = pd.read_excel(self.file_path,
                               true_values=['Yes', 'Y', 'yes', 'y', 1],
                               false_values=['No', 'N', 'no', 'n', 0])
        except XLRDError:
            rows = pd.read_csv(self.file_path,
                               true_values=['Yes', 'Y', 'yes', 'y', '1'],
                               false_values=['No', 'N', 'no', 'n', '0'], sep='\t',
                               encoding = 'utf-8')
        named_cols = [c for c in rows.columns if not c.startswith('unnamed: ')]
        rows = rows.loc[:, named_cols]
        rows.columns = [c.lower() for c in rows.columns]
        return rows

    def update_paths(self, ref_data_obj):
        options = ref_data_obj.__dict__.iteritems()
        if self.preserve_arguments:
            options = {(k, v) for k, v in ref_data_obj.__dict__.iteritems() if k not in self.__dict__}
        self.__dict__.update(options)


def generateMetadataParser(args):
    return MetadataParser(args)


class MetadataParserChipseq(object):
    def __init__(self, **kwargs):
        self.obj = generateMetadataParser(kwargs['args_obj'])

    def __getattr__(self, attr):
        return getattr(self.obj, attr)

    def render_json(self, wf_conf, samples_list, data_dir, template_name):
        env = Environment(extensions=["jinja2.ext.do"], loader=FileSystemLoader(os.path.join(EXEC_DIR, "templates")))
        template = env.get_template(template_name + '.j2')
        json_str = template.render({'wf_conf': wf_conf,
                                    'samples_list': samples_list,
                                    'data_dir': data_dir,
                                    'conf_args': self
                                    })
        json_str = '\n'.join([l for l in json_str.split('\n') if l.strip() != ''])  # Remove empty lines
        return json_str

    def parse_metadata(self, data_dir):
        samples_dict = defaultdict(list)
        wf_conf_dict = {}
        for r in self.records:
            read_type = r['paired-end or single-end'].lower()
            sample_info = {'treatment': r['name']}
            wf_key = '-'.join([read_type])
            if 'control' in r.keys() and r['control'] and r['control'].upper() != 'NA':
                sample_info['control'] = r['control']
                wf_key += '-with-control'
            wf_conf_dict[wf_key] = {'rt': read_type,
                                    'st': sample_info.keys()}
            genome = consts.GENOME  # Default genome
            if 'genome' in r.keys():
                genome = r['genome']

            samples_dict[wf_key].append([sample_info, genome])
        for wf_key, samples_genomes in samples_dict.iteritems():
            if self.obj.separate_jsons:
                for si, s in enumerate(sorted(samples_genomes)):
                    sample, genome = s[0], s[1]
                    ref_dataset = consts.ReferenceDataset(genome)
                    self.update_paths(ref_dataset)
                    yield self.render_json(wf_conf_dict[wf_key], [sample], data_dir, self.experiment_type), wf_key, si

            else:
                samples_list, genomes_list = zip(*samples_genomes)
                if len(set(genomes_list)) > 1:
                    raise Exception('More than one genome specified (%s). Please create a different metadata file'
                                    ' per genome or provide a sjdb and specify the --separate-jsons argument' %
                                    ', '.join(set(genomes_list)))
                ref_dataset = consts.ReferenceDataset(genomes_list[0])
                self.update_paths(ref_dataset)
                yield self.render_json(wf_conf_dict[wf_key], sorted(samples_list), data_dir, self.experiment_type), wf_key, None


class MetadataParserAtacseq(object):
    def __init__(self, **kwargs):
        self.obj = generateMetadataParser(kwargs['args_obj'])

    def __getattr__(self, attr):
        return getattr(self.obj, attr)

    def render_json(self, wf_conf, samples_list, data_dir, template_name):
        env = Environment(extensions=["jinja2.ext.do"], loader=FileSystemLoader(os.path.join(EXEC_DIR, "templates")))
        template = env.get_template(template_name + '.j2')
        json_str = template.render({'wf_conf': wf_conf,
                                    'samples_list': samples_list,
                                    'data_dir': data_dir,
                                    'nthreads': self.nthreads,
                                    'conf_args': self
                                    })
        json_str = '\n'.join([l for l in json_str.split('\n') if l.strip() != ''])  # Remove empty lines
        return json_str

    def parse_metadata(self, data_dir):
        samples_dict = defaultdict(list)
        wf_conf_dict = {}
        for r in self.records:
            read_type = r['paired-end or single-end'].lower()
            sample_info = {'treatment': r['name']}
            wf_key = '-'.join([read_type])
            genome = consts.GENOME  # Default genome
            if 'genome' in r.keys():
                genome = r['genome']
            if not ('blacklist removal' in r.keys() and is_false(r['blacklist removal'])):
                wf_key += '-blacklist-removal'

            wf_conf_dict[wf_key] = {'rt': read_type}
            samples_dict[wf_key].append([sample_info, genome])
        for wf_key, samples_genomes in samples_dict.iteritems():
            if self.obj.separate_jsons:
                for si, s in enumerate(sorted(samples_genomes)):
                    sample, genome = s[0], s[1]
                    ref_dataset = consts.ReferenceDataset(genome)
                    if 'blacklist-removal' not in wf_key:
                        ref_dataset.encode_blacklist_bedfile = None
                    self.update_paths(ref_dataset)
                    yield self.render_json(wf_conf_dict[wf_key], [sample], data_dir, self.experiment_type), wf_key, si
            else:
                samples_list = [s[0] for s in samples_genomes]
                genomes_list = [g[1] for g in samples_genomes]
                if len(set(genomes_list)) > 1:
                    raise Exception('More than one genome specified (%s). Please create a different metadata file'
                                    ' per genome or provide a sjdb and specify the --separate-jsons argument' %
                                    ', '.join(set(genomes_list)))
                ref_dataset = consts.ReferenceDataset(genomes_list[0])
                if 'blacklist-removal' not in wf_key:
                    ref_dataset.encode_blacklist_bedfile = None
                self.update_paths(ref_dataset)
                yield self.render_json(wf_conf_dict[wf_key], sorted(samples_list), data_dir, self.experiment_type), wf_key, None


class MetadataParserRnaseq(object):
    def __init__(self, **kwargs):
        self.obj = generateMetadataParser(kwargs['args_obj'])
        self.skip_star_2pass = kwargs['args_obj'].skip_star_2pass

    def __getattr__(self, attr):
        return getattr(self.obj, attr)

    def render_json(self, wf_conf, samples_list, data_dir):
        env = Environment(extensions=["jinja2.ext.do"], loader=FileSystemLoader(os.path.join(EXEC_DIR, "templates")))
        template = env.get_template(self.experiment_type + '.j2')
        json_str = template.render({'wf_conf': wf_conf,
                                    'samples_list': samples_list,
                                    'data_dir': data_dir,
                                    'nthreads': self.nthreads,
                                    'conf_args': self
                                    })
        json_str = '\n'.join([l for l in json_str.split('\n') if l.strip() != ''])  # Remove empty lines
        return json_str

    def parse_metadata(self, data_dir):
        samples_dict = defaultdict(list)
        wf_conf_dict = {}
        for rix, r in self.records.iterrows():
            read_type = r['paired-end or single-end'].lower()
            sample_name = r['name']
            strand_specific = r['strand specificity']
            genome = consts.GENOME  # Default genome
            if 'genome' in r.keys():
                genome = r['genome']
            ercc_spikein = False
            if 'with ercc spike-in' in r.keys():
                ercc_spikein = r['with ercc spike-in']
            kws = [read_type,  strand_specific]
            if self.skip_star_2pass:
                kws.append('with-sjdb')
            wf_key = '-'.join(kws)
            wf_conf_dict[wf_key] = {'rt': read_type, 'sn': sample_name}
            read_length = self.read_length
            if 'read length' in r.keys():
                read_length = int(r['read length'])
            samples_dict[wf_key].append([sample_name, genome, ercc_spikein, read_length])
        for wf_key, samples_genomes in samples_dict.iteritems():
            if self.obj.separate_jsons:
                for si, s in enumerate(sorted(samples_genomes)):
                    sample, genome, ercc_spikein, read_length = s
                    ref_dataset = consts.ReferenceDataset(genome,
                                                          read_length=read_length,
                                                          with_ercc=ercc_spikein)
                    self.update_paths(ref_dataset)

                    yield self.render_json(wf_conf_dict[wf_key], [sample], data_dir), wf_key, si
            else:
                samples_list = [s[0] for s in samples_genomes]
                genomes_list = [g[1] for g in samples_genomes]
                ercc_list = [e[2] for e in samples_genomes]
                read_length_list = [l[3] for l in samples_genomes]
                if len(set(genomes_list)) > 1:
                    raise Exception(
                        'More than one genome specified (%s). Please create a different metadata file'
                        ' per genome or provide a sjdb and specify the --separate-jsons argument' %
                        ', '.join(set(genomes_list)))
                if len(set(ercc_list)) > 1:
                    raise Exception(
                        'With and without ERCC spike-in specified. Please create a different metadata file'
                        ' per ERCC choice or provide a sjdb and specify the --separate-jsons argument')
                if len(set(read_length_list)) > 1:
                    raise Exception(
                        'More than one read length specified. Please create a different metadata file'
                        ' per read length choice or provide a sjdb and specify the --separate-jsons argument')
                ref_dataset = consts.ReferenceDataset(genomes_list[0],
                                                      read_length=read_length_list[0],
                                                      with_ercc=ercc_list[0])
                self.update_paths(ref_dataset)
                yield self.render_json(wf_conf_dict[wf_key], sorted(samples_list), data_dir), wf_key, None

class MetadataParserStarrseq(object):
    def __init__(self, **kwargs):
        self.obj = generateMetadataParser(kwargs['args_obj'])

    def __getattr__(self, attr):
        return getattr(self.obj, attr)

    def render_json(self, wf_conf, samples_list, data_dir):
        env = Environment(extensions=["jinja2.ext.do"], loader=FileSystemLoader(os.path.join(EXEC_DIR, "templates")))
        template = env.get_template(self.experiment_type + '.j2')
        json_str = template.render({'wf_conf': wf_conf,
                                    'samples_list': samples_list,
                                    'data_dir': data_dir,
                                    'nthreads': self.nthreads,
                                    'conf_args': self
                                    })
        json_str = '\n'.join([l for l in json_str.split('\n') if l.strip() != ''])  # Remove empty lines
        return json_str

    def parse_metadata(self, data_dir):
        samples_dict = defaultdict(list)
        wf_conf_dict = {}
        for rix, r in self.records.iterrows():
            read_type = r['paired-end or single-end'].lower()
            sample_name = r['name']
            genome = consts.GENOME  # Default genome
            if 'genome' in r.keys():
                genome = r['genome']
            kws = [read_type]
            wf_key = '-'.join(kws)
            with_umis = 'umis' in r.keys() and not is_false(r['umis'])
            if with_umis:
                wf_key += '-umis'

            wf_conf_dict[wf_key] = {'rt': read_type, 'sn': sample_name, 'umis': with_umis}
            samples_dict[wf_key].append([sample_name, genome])
        for wf_key, samples_genomes in samples_dict.iteritems():
            if self.obj.separate_jsons:
                for si, s in enumerate(sorted(samples_genomes)):
                    sample, genome = s[0], s[1]
                    ref_dataset = consts.ReferenceDataset(genome,
                                                          read_length=self.read_length)
                    self.update_paths(ref_dataset)

                    yield self.render_json(wf_conf_dict[wf_key], [sample], data_dir), wf_key, si
            else:
                samples_list = [s[0] for s in samples_genomes]
                genomes_list = [g[1] for g in samples_genomes]
                if len(set(genomes_list)) > 1:
                    raise Exception(
                        'More than one genome specified (%s). Please create a different metadata file'
                        ' per genome or provide a sjdb and specify the --separate-jsons argument' %
                        ', '.join(set(genomes_list)))
                ref_dataset = consts.ReferenceDataset(genomes_list[0],
                                                      read_length=self.read_length)
                self.update_paths(ref_dataset)
                yield self.render_json(wf_conf_dict[wf_key], sorted(samples_list), data_dir), wf_key, None


def main():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent('''
            Parse metadata and create workflow JSONs using templates
            --------------------------------------------------------
            '''))

    #############################
    # Base script options
    parser.add_argument('-o', '--outdir', metavar='output_dir', required=False, dest='outdir', type=str,
                        help='Output directory where the files will be placed.')
    parser.add_argument('-m', '--metadata-file', dest='meta_file', required=True,
                        help='Metadata file used to create the JSON config files. By convention, the file name should '
                             'start with the type of experiment, for example *chip-seq* or *chip_seq*. '
                             'Internally, this name is used identify the target template.')
    parser.add_argument('-d', '--data-dir', dest='data_dir', required=True,
                        help='Project directory containing the fastq data files.')
    parser.add_argument('-t', '--metadata-type', dest='data_type', choices=['chip-seq', 'rna-seq', 'atac-seq', 'starr-seq'],
                        default='chip-seq', help='Experiment type for the metadata.')
    parser.add_argument('--nthreads', type=int, dest='nthreads', default=consts.CPUS, help='Number of threads.')
    parser.add_argument('--mem', type=int, dest='mem', default=consts.MEM, help='Memory for Java based CLT.')
    parser.add_argument('--separate-jsons', action='store_true', help='Create one JSON per sample in the metadata.')
    parser.add_argument('--skip-star-2pass', action='store_true', default=False,
                        help='''[RNA-seq only]
                             Skip the STAR 2-pass step and use the genomeDir index for mapping.
                             By default, a STAR 2-pass strategy if implemented to create a splice junctions
                             file used to create a new STAR genome.''')
    parser.add_argument('--preserve-arguments', action='store_true', default=False,
                        help='''Preserve options specified in the command line over default values stored in consts.py''')
    #############################
    # Overwrittable default paths
    parser.add_argument('--read-length', help='Read length of the sequenced FASTQ files.',
                        type=int, default=consts.READ_LENGTH)
    parser.add_argument('--default-adapters', help='File with adapter sequences to be trimmed out).')
    parser.add_argument('--genome-ref-first-index', help='[non RNA-seq only] First index file of the Bowtie reference genome.')
    parser.add_argument('--genome-sizes-file', help='Chromosome sizes file')
    parser.add_argument('--encode-blacklist-bedfile', help='ENCODE blacklist bedfile to mask out un-mappable regions')
    parser.add_argument('--genome-effective-size', help='Genome effective or mappable size. Used in some deeptools commands')
    parser.add_argument('--star-genome-dir', help='[RNA-seq only] Directory containing the STAR Genome files (indices).')
    parser.add_argument('--annotation-file', help='[RNA-seq only] Gene annotation GTF file')
    parser.add_argument('--genome-fasta-files', nargs="*", help='[RNA-seq only] Genome FASTA file')
    parser.add_argument('--rsem-dir',
                        help='[RNA-seq only] RSEM reference/index directory (all index files should be included in this directory)')
    parser.add_argument('--as-narrowPeak', default=consts.as_narrowPeak,
                        help='AutoSQL file defining non-standard fields for narrowPeak files '
                             '(formats available in https://github.com/ucscGenomeBrowser/kent/tree/master/src/hg/lib/encode)')
    parser.add_argument('--as-broadPeak', default=consts.as_broadPeak,
                        help='AutoSQL file defining non-standard fields for broadPeak files '
                             '(formats available in https://github.com/ucscGenomeBrowser/kent/tree/master/src/hg/lib/encode)')
    parser.add_argument('--bamtools-forward-filter', default=consts.bamtools_forward_filter,
                        help='Rules for forward reads used in Bamtools')
    parser.add_argument('--bamtools-reverse-filter', default=consts.bamtools_reverse_filter,
                        help='Rules for reverse reads used in Bamtools')
    parser.add_argument('--trimmomatic-jar', default=consts.trimmomatic_jar,
                        help='Trimmomatic JAVA jar file')
    parser.add_argument('--picard-jar', default=consts.picard_jar,
                        help='Picard JAVA jar file')

    # Parse input
    args = parser.parse_args()

    if os.path.isfile(args.outdir):
        print "[ERROR] :: Target output directory is an existing file."
        sys.exit(1)

    if args.outdir and not os.path.exists(args.outdir):
        os.mkdir(args.outdir)

    if args.data_type == 'chip-seq':
        meta_parser = MetadataParserChipseq(args_obj=args)
    elif args.data_type == 'rna-seq':
        meta_parser = MetadataParserRnaseq(args_obj=args)
    elif args.data_type == 'atac-seq':
        meta_parser = MetadataParserAtacseq(args_obj=args)
    elif args.data_type == 'starr-seq':
        meta_parser = MetadataParserStarrseq(args_obj=args)
    else:
        raise Exception('Unrecognized Experiment Type: %s' % args.data_type)

    file_basename = os.path.splitext(os.path.basename(args.meta_file))[0]
    for json_str, conf_name, idx in meta_parser.parse_metadata(args.data_dir.rstrip('/')):
        if args.separate_jsons:
            conf_name += '-%d' % idx
        save_or_print_json(json_str, args.outdir, file_basename + '-' + conf_name)


if __name__ == '__main__':
    main()
