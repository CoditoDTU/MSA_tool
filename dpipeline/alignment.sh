#!/bin/bash

# Function to perform MSA for a given cluster
perform_msa() {
    # Local variables within function
    local folder_path="$1"
    local hmm_file="$2"
    local prefix="$3"
    local cluster_number="$4"

    local input_file="$folder_path${prefix}_clu_seq.$cluster_number" # .seq file which corresponds to Cluster 
    local output_file="$folder_path${prefix}_MSA_cluster${cluster_number}.fasta"

    echo "Processing file: $input_file"
    echo "Input file: $input_file"
    echo "Output file: $output_file"

    # Placeholder for the actual clustalo command
    clustalo -i "$input_file" --hmm-in "$hmm_file" -o "$output_file"

    echo "MSA for cluster $cluster_number completed."
}


# Function to display usage information
usage() {
    echo "Usage: $0 -hmm <hmm_file> -i <input_results_folder> -p <prefix>"
    echo "Options:"
    echo "  -h, --hmm        Path to the HMM file"
    echo "  -i, --input      Path to the results folder ex: data/ do not forget the /"
    echo "  -p, --prefix     Prefix for file matching"
    echo "  -help            Display this help message"
    exit 0  # Exit successfully after showing usage information
}


# Parse command-line options
while getopts "h:i:p:" opt; do
    case $opt in
        h)
            hmm_file="$OPTARG"
            ;;
        i)
            folder_path="$OPTARG"
            ;;
        p)
            prefix="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            usage
            ;;
    esac
done

#checks whether the first command-line argument is equal to --help. 
# If the user runs the script with --help, it triggers the usage function to display the help message.
if [ "$1" == "--help" ]; then
    usage
fi

# Check if the required options are provided
if [ -z "$hmm_file" ] || [ -z "$folder_path" ] || [ -z "$prefix" ]; then
    echo "Error: All options (-hmm, -i, -p) must be provided."
    usage
fi

# Loop through each file in the folder with the pattern ${prefix}_clu_seq.*
for file in "$folder_path/${prefix}_clu_seq".*; do
    # Extract cluster number from the file name
    cluster_number=$(basename "$file" | grep -oP "(?<=${prefix}_clu_seq\.)[0-9]+")
    
    # Check if the cluster number is valid (non-empty and numerical)
    if [[ -n "$cluster_number" ]] && [[ "$cluster_number" =~ ^[0-9]+$ ]]; then
        perform_msa "$folder_path" "$hmm_file" "$prefix" "$cluster_number"
    else
        echo "Skipping file $file as it does not match the expected pattern."
    fi
done

