#!/bin/bash

# Function to convert a sequence file to FASTA format
convert_seq_to_fasta() {
    local input_file="$1"  # Input sequence file
    local output_file="$2"  # Output FASTA file

    # Replace the beginning of each sequence with ">"
    sed 's/^.*>/>/' "$input_file" > "$output_file"

    # Remove the last line (usually contains a single character)
    sed -i '$d' "$output_file"

    rm "$input_file"
}


# Function to add OG sequence to the modified FASTA file
select_cluster_withOG() {
    local fasta_file="$1"      # Path to the modified FASTA file
    local og_sequence_file="$2"  # Path to the OG sequence file
    local temp_input_file="$3"  # Temporary copy of the original FASTA file

    # Call Python script to add OG sequence
    python3 add_ogseq.py -i "$fasta_file" -o "$temp_input_file" -f "$og_sequence_file"
    
    rm "$fasta_file"
}



# Function to perform MSA for a given cluster
perform_msa() {
    local fasta_file="$1"  # Path to the modified FASTA file
    local hmm_file="$2"    # Path to the HMM file
    # Remove ".fasta" extension from the input file name
    local input_file_name="${fasta_file%.fasta}"

    # Perform MSA using ClustalOmega
    clustalo -i "$fasta_file" --hmm-in "$hmm_file" -o "${input_file_name}_aligned.fasta"

    # Inform user that MSA for the cluster is completed
    echo "MSA for file $fasta_file completed."
}


# Function to display usage information
usage() {
    echo "Usage: $0 -H <hmm_file> -i <input_results_folder> -p <prefix> -f <og_sequence_file>"
    echo "Options:"
    echo "  -H <hmm_file>: Path to the HMM file"
    echo "  -i <input_results_folder>: Path to the results folder (e.g., data/)"
    echo "  -p <prefix>: Prefix for file matching"
    echo "  -f <og_sequence_file>: Path to the file containing the OG sequence"
    exit 1
}

# Parse command-line options
while getopts "H:i:p:f:" opt; do
    case $opt in
        H)
            hmm_file="$OPTARG"   # Store the provided HMM file path
            ;;
        i)
            folder_path="$OPTARG"  # Store the provided input folder path
            ;;
        p)
            prefix="$OPTARG"   # Store the provided prefix for file matching
            ;;
        f)
            og_sequence_file="$OPTARG"  # Store the provided OG sequence file path
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage  # Display usage information if an invalid option is provided
            ;;
    esac
done

# Check if the required options are provided
if [ -z "$hmm_file" ] || [ -z "$folder_path" ] || [ -z "$prefix" ] || [ -z "$og_sequence_file" ]; then
    echo "Error: All options (-H, -i, -p, -f) must be provided."
    usage  # Display usage information if any of the required options are missing
fi

# Loop through each file in the folder with the pattern ${prefix}_clu_seq*
for file in "$folder_path/${prefix}_clu_seq".*; do
    # Extract cluster number from the file name
    cluster_number=$(basename "$file" | grep -oP "(?<=${prefix}_clu_seq\.)[0-9]+")

    # Check if the cluster number is valid (non-empty and numerical)
    if [[ -n "$cluster_number" ]] && [[ "$cluster_number" =~ ^[0-9]+$ ]]; then
        # Convert sequence file to FASTA format
        fasta_file="$folder_path/${prefix}_clu_seq${cluster_number}.fasta"
        convert_seq_to_fasta "$file" "$fasta_file" "$folder_path"

        fasta_fileog="$folder_path/${prefix}_clu_seq${cluster_number}_og.fasta"
        # Add OG sequence to the FASTA file
        #add_og_sequence "$fasta_file" "$og_sequence_file" "$fasta_fileog"

        
        # Perform MSA on the modified FASTA file
        perform_msa "$fasta_fileog" "$hmm_file" "$folder_path"
    else
        echo "Skipping file $file as it does not match the expected pattern."
    fi
done
