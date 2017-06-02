import textwrap
import csv
import argparse
from collections import defaultdict

import sys
from jinja2 import Environment, FileSystemLoader
import os
import consts

encoding = sys.getfilesystemencoding()
EXEC_DIR = os.path.dirname(unicode(__file__, encoding)) + "/"


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
        self.genome_ref_first_index = args.genome_ref_first_index
        self.genome_sizes_file = args.genome_sizes_file
        self.encode_blacklist_bedfile = args.encode_blacklist_bedfile
        self.trimmomatic_jar = args.trimmomatic_jar
        self.picard_jar = args.picard_jar
        self.as_narrowPeak = args.as_narrowPeak

    def render_json(self, wf_conf, samples_list, data_dir, template_name):
        pass

    def parse_metadata(self, data_dir):
        pass

    def load_file(self):
        rows = []
        with open(self.file_path, 'rb') as f:
            reader = csv.DictReader(filter(lambda row: row[0] != '#', f), delimiter='\t')
            for row in reader:
                rows.append(row)
        return rows

    def update_paths(self, ref_data_obj):
        self.__dict__.update(ref_data_obj.__dict__)


def generateMetadataParser(args):
    return MetadataParser(args)


class MetadataParserChipseq(object):
    def __init__(self, **kwargs):
        self.obj = generateMetadataParser(kwargs['args_obj'])

    def __getattr__(self, attr):
        return getattr(self.obj, attr)

    def render_json(self, wf_conf, samples_list, data_dir, template_name):
        env = Environment(extensions=["jinja2.ext.do"], loader=FileSystemLoader(os.path.join(EXEC_DIR, "templates/")))
        template = env.get_template(template_name + '.j2')
        json_str = template.render({'wf_conf': wf_conf,
                                    'samples_list': samples_list,
                                    'data_dir': data_dir,
                                    'nthreads': self.nthreads,
                                    'mem': self.mem
                                    })
        json_str = '\n'.join([l for l in json_str.split('\n') if l.strip() != ''])  # Remove empty lines
        return json_str

    def parse_metadata(self, data_dir):
        samples_dict = defaultdict(list)
        wf_conf_dict = {}
        for r in self.records:
            read_type = r['Paired-end or single-end'].lower()
            peak_type = r['Peak type'].lower()
            sample_info = {'treatment': r['Name'],
                           'iter': r['Iter num']}
            wf_key = '-'.join([read_type, peak_type])
            if 'Control' in r.keys() and r['Control'] and r['Control'].upper() != 'NA':
                sample_info['control'] = r['Control']
                wf_key += '-with-control'
            wf_conf_dict[wf_key] = {'rt': read_type,
                                    'pt': peak_type,
                                    'st': sample_info.keys()}
            samples_dict[wf_key].append(sample_info)
        for wf_key, samples_list in samples_dict.iteritems():
            if self.obj.separate_jsons:
                for si, s in enumerate(sorted(samples_list)):
                    yield self.render_json(wf_conf_dict[wf_key], [s], data_dir, self.experiment_type), wf_key, si
            else:
                yield self.render_json(wf_conf_dict[wf_key], sorted(samples_list), data_dir, self.experiment_type), wf_key, None


class MetadataParserAtacseq(object):
    def __init__(self, **kwargs):
        self.obj = generateMetadataParser(kwargs['args_obj'])

    def __getattr__(self, attr):
        return getattr(self.obj, attr)

    def render_json(self, wf_conf, samples_list, data_dir, template_name):
        env = Environment(extensions=["jinja2.ext.do"], loader=FileSystemLoader(os.path.join(EXEC_DIR, "templates/")))
        template = env.get_template(template_name + '.j2')
        json_str = template.render({'wf_conf': wf_conf,
                                    'samples_list': samples_list,
                                    'data_dir': data_dir,
                                    'nthreads': self.nthreads,
                                    'mem': self.mem,
                                    'conf_args': self
                                    })
        json_str = '\n'.join([l for l in json_str.split('\n') if l.strip() != ''])  # Remove empty lines
        return json_str

    def parse_metadata(self, data_dir):
        samples_dict = defaultdict(list)
        wf_conf_dict = {}
        for r in self.records:
            read_type = r['Paired-end or single-end'].lower()
            sample_info = {'treatment': r['Name'],
                           'iter': r['Iter num']}
            wf_key = '-'.join([read_type])
            genome = 'hg38'  # Default genome
            if 'Genome' in r.keys():
                genome = r['Genome']
                print "[WARNING]:: overwriting reference data sets with the genome specified in metadata: %s" % genome
            if not ('Blacklist removal' in r.keys() and is_false(r['Blacklist removal'])):
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
        self.genomeDir = kwargs['args_obj'].genomeDir
        self.skip_star_2pass = kwargs['args_obj'].skip_star_2pass

    def __getattr__(self, attr):
        return getattr(self.obj, attr)

    def render_json(self, wf_conf, samples_list, data_dir):
        env = Environment(extensions=["jinja2.ext.do"], loader=FileSystemLoader(os.path.join(EXEC_DIR, "templates/")))
        template = env.get_template(self.experiment_type + '.j2')
        json_str = template.render({'wf_conf': wf_conf,
                                    'samples_list': samples_list,
                                    'data_dir': data_dir,
                                    'nthreads': self.nthreads,
                                    'mem': self.mem,
                                    'genomeDir': self.genomeDir
                                    })
        json_str = '\n'.join([l for l in json_str.split('\n') if l.strip() != ''])  # Remove empty lines
        return json_str

    def parse_metadata(self, data_dir):
        samples_dict = defaultdict(list)
        wf_conf_dict = {}
        for r in self.records:
            read_type = r['Paired-end or single-end'].lower()
            sample_name = r['Name']
            strand_specific = r['Strand specificity']
            kws = [read_type,  strand_specific]
            if self.skip_star_2pass:
                kws.append('with-sjdb')
            wf_key = '-'.join(kws)
            wf_conf_dict[wf_key] = {'iter': r['Iter num'], 'rt': read_type, 'sn': sample_name}
            samples_dict[wf_key].append(sample_name)
        for wf_key, samples_list in samples_dict.iteritems():
            if self.obj.separate_jsons:
                for si, s in enumerate(sorted(samples_list)):
                    yield self.render_json(wf_conf_dict[wf_key], [s], data_dir), wf_key, si
            else:
                yield self.render_json(wf_conf_dict[wf_key], sorted(samples_list), data_dir), wf_key, None


def main():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent('''
            Parse metadata and create workflow JSONs using templates
            --------------------------------------------------------
            '''))

    # Base script options
    parser.add_argument('-o', '--outdir', metavar='output_dir', required=False, dest='outdir', type=str,
                        help='Output directory where the files will be placed.')
    parser.add_argument('-m', '--metadata-file', dest='meta_file', required=True,
                        help='Metadata file used to create the JSON config files. By convention, the file name should '
                             'start with the type of experiment, for example *chip-seq* or *chip_seq*. '
                             'Internally, this name is used identify the target template.')
    parser.add_argument('-d', '--data-dir', dest='data_dir', required=True,
                        help='Project directory containing the fastq data files.')
    parser.add_argument('-t', '--metadata-type', dest='data_type', choices=['chip-seq', 'rna-seq', 'atac-seq'],
                        default='chip-seq', help='Experiment type for the metadata.')
    parser.add_argument('--nthreads', type=int, dest='nthreads', default=16, help='Number of threads.')
    parser.add_argument('--mem', type=int, dest='mem', default=16000, help='Memory for Java based CLT.')
    parser.add_argument('--separate-jsons', action='store_true', help='Create one JSON per sample in the metadata.')
    parser.add_argument('--default-adapters', default='/data/reddylab/projects/GGR/auxiliary/adapters/default_adapters.fasta',
                        help='File with adapter sequences to be trimmed out).')
    parser.add_argument('--genome-ref-first-index', default='/data/reddylab/Reference_Data/Genomes/hg38/GCA_000001405.15_GRCh38_no_alt_analysis_set.1.ebwt',
                        help='[non RNA-seq only] First index file of the Bowtie reference genome.')
    parser.add_argument('--genome-sizes-file', default='/data/reddylab/projects/GGR/auxiliary/hg38.sizes',
                        help='Chromosome sizes file')
    parser.add_argument('--as-narrowPeak', default='/data/reddylab/Reference_Data/ENCODE/kent/src/hg/lib/encode/narrowPeak.as',
                        help='AutoSQL file defining non-standard fields for narrowPeak files '
                             '(formats available in https://github.com/ucscGenomeBrowser/kent/tree/master/src/hg/lib/encode)')
    parser.add_argument('--encode-blacklist-bedfile', default='/data/reddylab/Reference_Data/ENCODE/hg38.blacklist.bed',
                        help='ENCODE blacklist bedfile to mask out un-mappable regions')
    parser.add_argument('--trimmomatic-jar', default='/data/reddylab/software/Trimmomatic-0.32/trimmomatic-0.32.jar',
                        help='Trimmomatic JAVA jar file')
    parser.add_argument('--picard-jar', default='/data/reddylab/software/picard/dist/picard.jar',
                        help='Picard JAVA jar file')
    parser.add_argument('--genomeDir', default='/data/reddylab/Reference_Data/Genomes/hg38/STAR_genome_sjdbOverhang_49',
                        help='[RNA-seq only] Directory containing the STAR Genome files (indices).')
    parser.add_argument('--skip-star-2pass', action='store_true', default=False,
                        help='''[RNA-seq only]
                             Skip the STAR 2-pass step and use the genomeDir index for mapping.
                             By default, a STAR 2-pass strategy if implemented to create a splice junctions
                             file used to create a new STAR genome.''')

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
    else:
        raise Exception('Unrecognized Experiment Type: %s' % args.data_type)

    file_basename = os.path.splitext(os.path.basename(args.meta_file))[0]
    for json_str, conf_name, idx in meta_parser.parse_metadata(args.data_dir.rstrip('/')):
        if args.separate_jsons:
            conf_name += '-%d' % idx
        save_or_print_json(json_str, args.outdir, file_basename + '-' + conf_name)


if __name__ == '__main__':
    main()
