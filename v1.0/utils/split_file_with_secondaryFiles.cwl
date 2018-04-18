 class: ExpressionTool
 cwlVersion: v1.0
 doc: Split a CWL File object into primary and secondary files.
 requirements:
    InlineJavascriptRequirement: {}
 inputs:
    input_file_obj: {type: File}
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
    sec_files:
      type: File[]
    primary_file:
      type: File
