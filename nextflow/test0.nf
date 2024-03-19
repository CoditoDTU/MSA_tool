#!/usr/bin/env nextflow

params.data = "/home/codito/Documents/MSA_tool/nextflow/data/dummy_data.fasta"
params.functions = "/home/codito/Documents/MSA_tool/nextflow/functions/"

// Define channels
data_ch = Channel.fromPath(params.data)
functions_ch = Channel.fromPath(params.functions)

process filter {
  input:
  path rawFasta 
  path fun_path 
  
  script:
  """
  bash ${fun_path}/filter.sh -i ${rawFasta} -o results/test_output.fasta -l 49
  """
}
workflow {
   filter(data_ch, functions_ch)
}

//workflow{
  //data_ch = Channel.fromPath(params.data)
  //functions_ch = Channel.fromPath(params.functions)
  //data_ch.set

  // Call the filter process with both input channels
  //results_ch = filter(data_ch, functions_ch)

  // View the results channel
  //results_ch.view { it }
//}