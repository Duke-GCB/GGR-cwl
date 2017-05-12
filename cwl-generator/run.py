import textwrap
import yaml
import argparse
from jinja2 import Environment, PackageLoader, FileSystemLoader
import os


def get_cwl_name(template_name, conf_obj):
    if 'chipseq-pipeline' == template_name:
        if "control" not in conf_obj['sample_types']:
            suf_list = [conf_obj['read_type'], conf_obj['peak_type']]
        else:
            suf_list = [conf_obj['read_type'], conf_obj['peak_type'], 'with-control']
        return "pipeline-%s" % '-'.join(suf_list)
    if 'chipseq-04-peakcall' == template_name:
        if "control" not in conf_obj['sample_types']:
            suf_list = [conf_obj['peak_type']]
        else:
            suf_list = [conf_obj['peak_type'], 'with-control']
        return "04-peakcall-%s" % '-'.join(suf_list)
    if 'chipseq-03-map' == template_name:
        return "03-map-%s" % conf_obj['read_type']
    if 'chipseq-02-trim' == template_name:
        return "02-trim-%s" % conf_obj['read_type']
    if 'chipseq-01-qc' == template_name:
        return "01-qc-%s" % conf_obj['read_type']

    if 'rnaseq-pipeline' == template_name:
        if not conf_obj['star2pass']:
            return "pipeline-%s-with-sjdb" % '-'.join([conf_obj['read_type'], conf_obj['strandness']])
        return "pipeline-%s" % '-'.join([conf_obj['read_type'], conf_obj['strandness']])
    if 'rnaseq-04-quantification' == template_name:
        return "04-quantification-%s" % '-'.join([conf_obj['read_type'], conf_obj['strandness']])
    if 'rnaseq-03-map' == template_name:
        if conf_obj['star2pass']:
            return "03-map-%s" % '-'.join([conf_obj['read_type']])
        return "03-map-%s-with-sjdb" % '-'.join([conf_obj['read_type']])
    if 'rnaseq-02-trim' == template_name:
        return "02-trim-%s" % conf_obj['read_type']
    if 'rnaseq-01-qc' == template_name:
        return "01-qc-%s" % conf_obj['read_type']

    if 'atacseq-pipeline' == template_name:
        suf_list = [conf_obj['read_type']]
        if conf_obj['blacklist_removal']:
            suf_list.append('blacklist-removal')
        return "pipeline-%s" % '-'.join(suf_list)
    if 'atacseq-03-map' == template_name:
        suf_list = [conf_obj['read_type']]
        if conf_obj['blacklist_removal']:
            suf_list.append('blacklist-removal')
        return "03-map-%s" % '-'.join(suf_list)
    if template_name in ['atacseq-04-peakcall', 'atacseq-02-trim', 'atacseq-01-qc']:
        return "%s-%s" % (template_name.replace('atacseq-', ''), conf_obj['read_type'])

    return None


def write_template(cwl_str, outdir, templ_name, conf_params):
    if outdir:
        cwl_name = get_cwl_name(templ_name, conf_params)
        with open("%s/%s.cwl" % (outdir, cwl_name), 'w') as cout:
            cout.writelines(cwl_str)
    else:
        print cwl_str


def render_cwl_from_yaml(yaml_path, outdir):
    with open(yaml_path) as yaml_file:
        conf_obj = yaml.load(yaml_file)
    template_name = os.path.splitext(os.path.basename(yaml_path))[0]
    env = Environment(loader=FileSystemLoader('%s/templates/' % os.path.dirname(__file__)))
    template = env.get_template(template_name + '.j2')
    for conf_params in conf_obj:
        cwl_str = template.render(conf_params)
        cwl_str = '\n'.join([l for l in cwl_str.split('\n') if l.strip() != ''])  # Remove empty lines
        write_template(cwl_str, outdir, template_name, conf_params)


def main():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
            description=textwrap.dedent('''
            CWL generator - Create GGR CWL workflows using templates
            --------------------------------------------------------
            '''))

    # Base script options
    parser.add_argument('-o', '--outdir', metavar='output_dir', dest='outdir', type=str,
                             help='Output directory where the files will be placed.')
    parser.add_argument('-c', '--config-yaml', dest='config_yaml', required=True,
                             help='Config file used while rendering the CWL file.')

    # Parse input
    args = parser.parse_args()

    if args.outdir and not os.path.isdir(args.outdir):
        os.mkdir(args.outdir)

    # Generate outputs
    render_cwl_from_yaml(args.config_yaml, args.outdir)

if __name__ == '__main__':
    main()