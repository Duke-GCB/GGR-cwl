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
    def __init__(self, file_path):
        self.file_path = file_path
        self.experiment_type = os.path.splitext(os.path.basename(file_path))[0].split('_')[0].split('.')[0].split('-')[0]
        self.records = self.load_file()

    def render_json(self, wf_conf, samples_list, data_dir, template_name):
        env = Environment(loader=PackageLoader(package_name='json-generator'))
        template = env.get_template(template_name + '.j2')
        json_str = template.render({'wf_conf': wf_conf, 'samples_list': samples_list, 'data_dir': data_dir})
        json_str = '\n'.join([l for l in json_str.split('\n') if l.strip() != ''])  # Remove empty lines
        return json_str

    def parse_metadata(self, data_dir):
        samples_dict = defaultdict(list)
        wf_conf_dict = {}
        for r in self.records:
            read_type = r['Paired-end or single-end'].lower()
            peak_type = r['Peak type'].lower()
            sample_names = {'treatment': r['Name']}
            wf_key = '-'.join([read_type, peak_type])
            if 'Control' in r.keys():
                sample_names['control'] = r['Control']
                wf_key += '-with-control'
            wf_conf_dict[wf_key] = {'iter': r['Iter num'], 'rt': read_type, 'pt': peak_type, 'st': sample_names.keys()}
            samples_dict[wf_key].append(sample_names)
        for wf_key, samples_list in samples_dict.iteritems():
            yield self.render_json(wf_conf_dict[wf_key], sorted(samples_list), data_dir, self.experiment_type), wf_key

    def load_file(self):
        rows = []
        with open(self.file_path, 'rb') as f:
            reader = csv.DictReader(f, delimiter='\t')
            for row in reader:
                rows.append(row)
        return rows


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

    # Parse input
    args = parser.parse_args()

    if args.outdir and os.path.isdir(args.outdir) and not os.path.exists(args.outdir):
        os.mkdir(args.outdir)

    # Generate outputs
    meta_parser = MetadataParser(args.meta_file)
    file_basename = os.path.splitext(os.path.basename(args.meta_file))[0]
    for json_str, conf_name in meta_parser.parse_metadata(args.data_dir.rstrip('/')):
        save_or_print_json(json_str, args.outdir, file_basename + '-' + conf_name)


if __name__ == '__main__':
    main()
