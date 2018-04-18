cwlVersion: "cwl:draft-3"
class: ExpressionTool
requirements:
  - class: InlineJavascriptRequirement
inputs:
  - {id: file_path, type: string}
  - {id: sep, description: "File extension delimiter", type: string, default: "."}
  - {id: num_ext, description: "Number of file extensions to remove", type: int, default: 1}
expression: |
    ${
      var out=inputs.file_path.replace(/^.*[\\\/]/, '');
      for (var e=0;e<inputs.num_ext; e++){
        out=out.split(RegExp(inputs.sep))[0];
      }
      return {"basename": out};
    }
outputs:
  - id: basename
    type: string
