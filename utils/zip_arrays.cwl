cwlVersion: "cwl:draft-3"
class: ExpressionTool
requirements:
  - class: InlineJavascriptRequirement
inputs:
  - {id: reads1, type: {type: array, items: File}}
  - {id: reads2, type: {type: array, items: File}}
expression: |
    ${
      var merged_list=[];
      for (var e=0;e<inputs.reads1.length; e++){
        merged_list.push([inputs.reads1[e], inputs.reads2[e]]);
      }
      return {"zipped_list": merged_list};
    }
outputs:
  - id: zipped_list
    type:
      type: array
      items:
        type: array
        items: File
