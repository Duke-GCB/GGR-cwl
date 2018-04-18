 class: ExpressionTool
 cwlVersion: v1.0
 requirements:
    InlineJavascriptRequirement: {}
 inputs:
    reads2:
      type: File[]
    reads1:
      type: File[]
 expression: |
    ${
      var merged_list=[];
      for (var e=0;e<inputs.reads1.length; e++){
        merged_list.push([inputs.reads1[e], inputs.reads2[e]]);
      }
      return {"zipped_list": merged_list};
    }
 outputs:
    zipped_list:
      type:
        type: array
        items:
          type: array
          items: File
