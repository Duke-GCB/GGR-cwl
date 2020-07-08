 class: ExpressionTool
 cwlVersion: v1.0
 requirements:
    InlineJavascriptRequirement: {}
 inputs:
    num_ext: {type: int, default: 1, doc: Number of file extensions to remove}
    file_path: {type: string}
    sep: {type: string, doc: File extension delimiter}
    do_not_escape_sep: {type: boolean, default: False}
 expression: |
    ${
      var sep_escaped = !inputs.do_not_escape_sep ? inputs.sep.replace(/[^\w\s]/g, "\\$&") : inputs.sep;
      var out=inputs.file_path.replace(/^.*[\\\/]/, '');
      for (var e=0;e<inputs.num_ext; e++){
        out=out.split(RegExp("\\b" + sep_escaped + "\\b"))[0];
      }
      return {"basename": out};
    }
 outputs:
    basename:
      type: string
