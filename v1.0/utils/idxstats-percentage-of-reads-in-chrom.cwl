 class: ExpressionTool
 cwlVersion: v1.0
 requirements:
    InlineJavascriptRequirement: {}
 inputs:
    idxstats:
      type: File
      doc: Samtools idxstats file
      inputBinding:
        loadContents: true
    chrom:
      type: string
      doc: Query chromosome used to calculate percentage
    output_filename:
      type: string?
      doc: Save the percentage in a file of the given name
 expression: |
    ${
      var regExp = new RegExp(inputs.chrom + "\\s\\d+\\s(\\d+)\\s(\\d+)");
      var match = inputs.idxstats.contents.match(regExp);
      if (match){
        var chrom_mapped_reads = match[1];
        var total_reads = inputs.idxstats.contents.split("\r")
          .map(function(x){
            var rr = x.match(/.*\s\d+\s(\d+)\s\d+/);
            return (rr ? rr[1] : 0);
          })
          .reduce(function(a, b) { return Number(a) + Number(b); });

        var output = (100*chrom_mapped_reads/total_reads).toFixed(4) + "%" + "\n";

        if (inputs.output_filename){
          return {
            percent_map : {
              "class": "File",
              "basename" : inputs.output_filename,
              "contents" : output,
            }
          }
        }
        return output;
      }
    }
 outputs:
    percent_map:
      type:
      - File
      - string
