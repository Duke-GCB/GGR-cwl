cwlVersion: "cwl:draft-3"
class: ExpressionTool
description: Split a CWL File object into primary and secondary files.
requirements:
  - class: InlineJavascriptRequirement
inputs:
  - {id: input_file_obj, type: File}
expression: |
    ${
      var sec_files = inputs.input_file_obj["secondaryFiles"]
      delete inputs.input_file_obj["secondaryFiles"];
      return {
        "primary_file": inputs.input_file_obj,
        "sec_files": sec_files
        };
    }
outputs:
  - id: primary_file
    type: File
  - id: sec_files
    type:
      type: array
      items: File
