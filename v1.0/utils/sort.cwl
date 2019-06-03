 class: CommandLineTool
 cwlVersion: v1.0
 doc: "Usage: sort [OPTION]... [FILE]...\nWrite sorted concatenation of all FILE(s) to standard output.\n\n\nMandatory arguments to long options are mandatory for short options too.\nOrdering options:\n\n\n\n  -b, --ignore-leading-blanks  ignore leading blanks\n\n  -d, --dictionary-order      consider only blanks and alphanumeric characters\n\n  -f, --ignore-case           fold lower case to upper case characters\n\n  -g, --general-numeric-sort  compare according to general numerical value\n\n  -i, --ignore-nonprinting    consider only printable characters\n\n  -M, --month-sort            compare (unknown) < `JAN' < ... < `DEC'\n\n  -n, --numeric-sort          compare according to string numerical value\n\n  -r, --reverse               reverse the result of comparisons\n\n\n\nOther options:\n\n\n\n  -c, --check               check whether input is sorted; do not sort\n\n  -k, --key=POS1[,POS2]     start a key at POS1, end it at POS2 (origin 1)\n\n  -m, --merge               merge already sorted files; do not sort\n\n  -o, --output=FILE         write result to FILE instead of standard output\n\n  -s, --stable              stabilize sort by disabling last-resort comparison\n\n  -S, --buffer-size=SIZE    use SIZE for main memory buffer\n\n  -t, --field-separator=SEP  use SEP instead of non-blank to blank transition\n\n  -T, --temporary-directory=DIR  use DIR for temporaries, not $TMPDIR or /tmp;\n\n                              multiple options specify multiple directories\n\n  -u, --unique              with -c, check for strict ordering;\n\n                              without -c, output only the first of an equal\nrun\n\n  -z, --zero-terminated     end lines with 0 byte, not newline\n\n      --help     display this help and exit\n\n      --version  output version information and exit\n\n\n\nPOS is F[.C][OPTS], where F is the field number and C the character position\nin the field.  OPTS is one or more single-letter ordering options, which\noverride global ordering options for that key.  If no key is given, use the\nentire line as the key.\n\n\nSIZE may be followed by the following multiplicative suffixes:\n% 1% of memory, b 1, K 1024 (default), and so on for M, G, T, P, E, Z, Y.\n\n\nWith no FILE, or when FILE is -, read standard input.\n\n\n*** WARNING ***\nThe locale specified by the environment affects sort order.\nSet LC_ALL=C to get the traditional sort order that uses\nnative byte values.\n\n\nReport bugs to <bug-coreutils@gnu.org>."
 requirements:
    InlineJavascriptRequirement: {}
    ShellCommandRequirement: {}
 hints:
    DockerRequirement:
      dockerPull: reddylab/workflow-utils:ggr
 inputs:
    input_file:
      type: File
      inputBinding:
        position: 1
    suffix:
      type: string
      default: .sorted.txt
    M:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -M
      doc: |
        --month-sort            compare (unknown) < `JAN' < ... < `DEC'
    S:
      type: int?
      inputBinding:
        position: 1
        prefix: -S
      doc: |
        --buffer-size=SIZE    use SIZE for main memory buffer
    d:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -d
      doc: |
        --dictionary-order      consider only blanks and alphanumeric characters
    c:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -c
      doc: |
        --check               check whether input is sorted; do not sort
    b:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -b
      doc: |
        --ignore-leading-blanks  ignore leading blanks
    g:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -g
      doc: |
        --general-numeric-sort  compare according to general numerical value
    f:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -f
      doc: |
        --ignore-case           fold lower case to upper case characters
    i:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -i
      doc: |
        --ignore-nonprinting    consider only printable characters
    k:
      type: string[]?
      inputBinding:
        position: 1
        itemSeparator: " -k "
        prefix: -k
        shellQuote: false
      doc: |
        --key=POS1[,POS2]     start a key at POS1, end it at POS2 (origin 1)
    m:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -m
      doc: |
        --merge               merge already sorted files; do not sort
    n:
      type: string?
      inputBinding:
        position: 1
        prefix: -n
      doc: |
        --numeric-sort          compare according to string numerical value
    s:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -s
      doc: |
        --stable              stabilize sort by disabling last-resort comparison
    r:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -r
      doc: |
        --reverse               reverse the result of comparisons
        Other options:
    u:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -u
      doc: |
        --unique              with -c, check for strict ordering;
        without -c, output only the first of an equal run
    t:
      type: string?
      inputBinding:
        position: 1
        prefix: -t
      doc: |
        --field-separator=SEP  use SEP instead of non-blank to blank transition
    z:
      type: boolean?
      inputBinding:
        position: 1
        prefix: -z
      doc: |
        --zero-terminated     end lines with 0 byte, not newline
 outputs:
    outfile:
      type: File
      outputBinding:
        glob: $(inputs.input_file.nameroot + inputs.suffix)
 baseCommand:
  - sort
 stdout: $(inputs.input_file.nameroot + inputs.suffix)
 arguments:
  - valueFrom: $(runtime.tmpdir)
    position: 1
    prefix: --temporary-directory