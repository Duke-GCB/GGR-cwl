import textwrap
import csv
import argparse
from collections import defaultdict
from jinja2 import Environment, PackageLoader
import os


def save_or_print_json(json_str, outdir, json_name):
    if outdir:
        with open("%s/%s.json" % (outdir, json_name), 'w') as cout:
            cout.writelines(json_str)
    else:
        print "#%s.json" % json_name
        print json_str


class MetadataParser(object):
    def __init__(self, **kwargs):
        self.nthreads = kwargs['nthreads']
        self.mem = kwargs['mem']
        self.file_path = kwargs['file_path']
        self.records = self.load_file()

    def render_json(self, wf_conf, samples_list, data_dir, template_name):
        pass

    def parse_metadata(self, data_dir):
        pass

    def load_file(self):
        rows = []
        with open(self.file_path, 'rb') as f:
            reader = csv.DictReader(f, delimiter='\t')
            for row in reader:
                rows.append(row)
        return rows


def generateMetadataParser(args):
    return MetadataParser(file_path=args.meta_file,
                          nthreads= args.nthreads,
                          mem=args.mem)


class MetadataParserChipseq(object):
    def __init__(self, **kwargs):
        self.obj = generateMetadataParser(kwargs['args_obj'])
        self.experiment_type = kwargs['exp_type']

    def __getattr__(self, attr):
        return getattr(self.obj, attr)

    def render_json(self, wf_conf, samples_list, data_dir, template_name):
        env = Environment(loader=PackageLoader(package_name='json-generator'))
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
            yield self.render_json(wf_conf_dict[wf_key], sorted(samples_list), data_dir, self.experiment_type), wf_key


class MetadataParserRnaseq(object):
    def __init__(self, **kwargs):
        self.obj = generateMetadataParser(kwargs['args_obj'])
        self.experiment_type = kwargs['exp_type']

    def __getattr__(self, attr):
        return getattr(self.obj, attr)

    def render_json(self, wf_conf, samples_list, data_dir, template_name):
        env = Environment(loader=PackageLoader(package_name='json-generator'))
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
            sample_name = r['Name']
            wf_key = '-'.join([read_type])
            wf_conf_dict[wf_key] = {'rt': read_type, 'sn': sample_name}
            samples_dict[wf_key].append({'name': sample_name, 'iter': r['Iter num']})
        for wf_key, samples_list in samples_dict.iteritems():
            yield self.render_json(wf_conf_dict[wf_key], sorted(samples_list), data_dir, self.experiment_type), wf_key



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
    parser.add_argument('-d', '--data-dir', dest='data_dir',
                        default='/data/reddylab/projects/GGR/data/chip_seq/processed_raw_reads',
                        help='Project directory containing the fastq data files.')
    parser.add_argument('-t', '--metadata-type', dest='data_type', choices=['chip-seq', 'rna-seq'],
                        default='chip-seq', help='Experiment type for the metadata.')
    parser.add_argument('--nthreads', type=int, dest='nthreads', default=16, help='Number of threads.')
    parser.add_argument('--mem', type=int, dest='mem', default=16000, help='Memory for Java based CLT.')

    # Parse input
    args = parser.parse_args()

    if os.path.isfile(args.outdir):
        print "[ERROR] :: Target output directory is an existing file."
        import sys
        sys.exit(1)

    if args.outdir and not os.path.exists(args.outdir):
        os.mkdir(args.outdir)

    if args.data_type == 'chip-seq':
        meta_parser = MetadataParserChipseq(args_obj=args, exp_type=args.data_type)
    elif args.data_type == 'rna-seq':
        meta_parser = MetadataParserRnaseq(args_obj=args, exp_type=args.data_type)

    file_basename = os.path.splitext(os.path.basename(args.meta_file))[0]
    for json_str, conf_name in meta_parser.parse_metadata(args.data_dir.rstrip('/')):
        save_or_print_json(json_str, args.outdir, file_basename + '-' + conf_name)


if __name__ == '__main__':
    main()
