#!/bin/bash

# Specify the path to the folder containing the gb1_clu_seq files (TEST: Trypsin)
folder_path="$HOME/Documents/MSA_tool/Tryp/results" 

# Specify the path to the .hmm file
hmm_file="$HOME/Documents/MSA_tool/Tryp/data/PF00089.hmm" # Trypsin .hmm

# Loop through each file in the folder with the pattern Tryp_clu_seq.*
for file in "$folder_path"/Tryp_clu_seq.*; do
    # Check if the file matches the expected pattern
    if [[ $file =~ Tryp_clu_seq\.([0-11]+)$ ]]; then
        cluster_number="${BASH_REMATCH[1]}"
        
        input_file="$folder_path/Tryp_clu_seq.$cluster_number"
        output_file="$folder_path/Tryp_MSA_cluster${cluster_number}.fasta"
        
        # Print debugging statements
        echo "Processing file: $file"
        echo "Input file: $input_file"
        echo "Output file: $output_file"
        
        clustalo -i "$input_file" --hmm-in "$hmm_file" -o "$output_file"
        
        echo "MSA for cluster $cluster_number completed."
    else
        echo "Skipping file $file as it does not match the expected pattern."
    fi
done


