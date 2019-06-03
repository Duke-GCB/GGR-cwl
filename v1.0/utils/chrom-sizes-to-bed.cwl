 class: ExpressionTool
 cwlVersion: v1.0
 requirements:
    InlineJavascriptRequirement: {}
 inputs:
    chrom_sizes:
      type: File
      doc: 2-column file with chromosome names and lengths
      inputBinding:
        loadContents: true
 expression: |
    ${
          var chrom_sizes = inputs.chrom_sizes.contents.replace(/^\s+|\s+$/g, '').split("\n")
              .map(function(x){
                  var chroms = x.split("\t");
                  return chroms[0] + "\t0\t" + chroms[1]
              })
              .reduce(function(a, b) { return a + "\n" + b });
          chrom_sizes += "\n";
          return {
            "bed": {
              "class": "File",
              "basename": inputs.chrom_sizes.basename.replace(/\.([^/.]+)$/, '.bed'),
              "contents": chrom_sizes,
             }
          }
    }
 outputs:
    bed:
      type: File
