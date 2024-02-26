#!/bin/bash

# Function to perform MSA for a given cluster
# Function to add header if missing and perform MSA for a given cluster
perform_msa() {
    # Local variables within function
    local folder_path="$1"
    local hmm_file="$2"
    local prefix="$3" # Name of protein for MSA
    local cluster_number="$4" 
    local header_file="$5" # .fasta file with OG querie seq

    local input_file="$folder_path${prefix}_clu_seq.$cluster_number" # .seq file which corresponds to Cluster 
    local output_file="$folder_path${prefix}_MSA_cluster${cluster_number}.fasta"

    echo "Processing file: $input_file"
    echo "Input file: $input_file"
    echo "Output file: $output_file"

    # Call Python script to add header if missing
    python3 add_ogseq.py -i "$input_file" -o "$output_file" -f "$header_file"

    

    # If output file doesn't exist (meaning header and sequence already present), use input file for MSA
    if [ ! -f "$output_file" ]; then
        input_for_clustalo="$input_file"
    else
        input_for_clustalo="$output_file"
    fi

    # Perform MSA using ClustalOmega
    echo -i "$input_for_clustalo" --hmm-in "$hmm_file" -o "${output_file}_aligned.fasta"

    echo "MSA for cluster $cluster_number completed."
}


# Function to display usage information
usage() {
    echo "Usage: $0 -H <hmm_file> -i <input_results_folder> -p <prefix> -f <header_file>"
    echo "Options:"
    echo "  -H <hmm_file>: Path to the HMM file"
    echo "  -i <input_results_folder>: Path to the results folder (e.g., data/)"
    echo "  -p <prefix>: Prefix for file matching"
    echo "  -f <header_file>: Path to the fasta file containing the header sequence"
    exit 1
}

# Parse command-line options
while getopts "H:i:p:f:" opt; do
    case $opt in
        H)
            hmm_file="$OPTARG"
            ;;
        i)
            folder_path="$OPTARG"
            ;;
        p)
            prefix="$OPTARG"
            ;;
        f)
            header_file="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done

# Check if the required options are provided
if [ -z "$hmm_file" ] || [ -z "$folder_path" ] || [ -z "$prefix" ] || [ -z "$header_file" ]; then
    echo "Error: All options (-H, -i, -p, -f) must be provided."
    usage
fi

# Loop through each file in the folder with the pattern ${prefix}_clu_seq.*
for file in "$folder_path/${prefix}_clu_seq".*; do
    # Extract cluster number from the file name
    cluster_number=$(basename "$file" | grep -oP "(?<=${prefix}_clu_seq\.)[0-9]+")
    
    # Check if the cluster number is valid (non-empty and numerical)
    if [[ -n "$cluster_number" ]] && [[ "$cluster_number" =~ ^[0-9]+$ ]]; then
        perform_msa "$folder_path" "$hmm_file" "$prefix" "$cluster_number" "$header_file"
    else
        echo "Skipping file $file as it does not match the expected pattern."
    fi
done