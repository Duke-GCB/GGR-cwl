 class: ExpressionTool
 cwlVersion: v1.0
 requirements:
    InlineJavascriptRequirement: {}
 inputs:
    num_ext: {type: int, default: 1, doc: Number of file extensions to remove}
    file_path: {type: string}
    sep: {type: string, default: ., doc: File extension delimiter}
 expression: |
    ${
      var out=inputs.file_path.replace(/^.*[\\\/]/, '');
      for (var e=0;e<inputs.num_ext; e++){
        out=out.split(RegExp(inputs.sep))[0];
      }
      return {"basename": out};
    }
 outputs:
    basename:
      type: string
