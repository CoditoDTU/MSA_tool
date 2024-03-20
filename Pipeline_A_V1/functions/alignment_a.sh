#!/bin/bash

# Function to convert a sequence file to FASTA format
convert_seq_to_fasta() {
    local input_sequence_file="$1"  # Input sequence file
    local output_fasta_file="$2"  # Output converted FASTA file

    # Replace the beginning of each sequence with ">"
    sed 's/^.*>/>/' "$input_sequence_file" > "$output_fasta_file"

    # Remove the last line (usually contains a single character)
    sed -i '$d' "$output_fasta_file"

    rm "$input_sequence_file"
}


# Function to add OG sequence to the modified FASTA file
add_og_sequence() {
    local inputFastaWithoutOG="$1"  # Path to the FASTA file without OG sequence
    local og_sequence_file="$2"  # Path to the OG sequence file
    local outputFastaWithOG="$3"  #  FASTA file with OG sequence added

    # Call Python script to add OG sequence
    python3 functions/add_ogseq.py -i "$inputFastaWithoutOG" -o "$outputFastaWithOG" -f "$og_sequence_file"
    
    rm "$inputFastaWithoutOG"
}



# Function to perform MSA for a given cluster
perform_msa() {
    local clusterFastaWithOGSequence="$1"  # Path to cluster fasta with OG
    local hmm_file="$2"    # Path to the HMM file
    # Remove ".fasta" extension from the input file name
    local inputClusterNameNoExtension="${clusterFastaWithOGSequence%.fasta}"

    # Perform MSA using ClustalOmega
    clustalo -i "$clusterFastaWithOGSequence" --hmm-in "$hmm_file" -o "${inputClusterNameNoExtension}_aligned.fasta"

    # Inform user that MSA for the cluster is completed
    echo "MSA for file $clusterFastaWithOGSequence completed."
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
        clusterFastaName="$folder_path/${prefix}_clu_seq${cluster_number}.fasta"

        convert_seq_to_fasta "$file" "$clusterFastaName" "$folder_path"

        fastaWithOG_name="$folder_path/${prefix}_clu_seq${cluster_number}_og.fasta"
        # Add OG sequence to the FASTA file
        add_og_sequence "$clusterFastaName" "$og_sequence_file" "$fastaWithOG_name"

        
        # Perform MSA on the modified FASTA file
        perform_msa "$fastaWithOG_name" "$hmm_file" "$folder_path"
    else
        echo "Skipping file $file as it does not match the expected pattern."
    fi
done
