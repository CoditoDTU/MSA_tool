#!/bin/bash

# Function to perform MSA for a given fasta file
perform_msa() {
    local input_file="$1"
    local hmm_file="$2"
    local og_sequence_file="$3"

    # Call Python script to add OG sequence
    python3 add_ogseq.py -i "$input_file" -o "${input_file}_with_og.fasta" -f "$og_sequence_file"

    # Perform MSA using ClustalOmega
    clustalo -i "${input_file}_with_og.fasta" --hmm-in "$hmm_file" -o "${input_file}_aligned.fasta"

    echo "MSA completed for $input_file."
}

# Function to display usage information
usage() {
    echo "Usage: $0 -i <input_fasta> -H <hmm_file> -f <og_sequence_file>"
    echo "Options:"
    echo "  -i <input_fasta>: Path to the input FASTA file"
    echo "  -H <hmm_file>: Path to the HMM file"
    echo "  -f <og_sequence_file>: Path to the file containing the OG sequence"
    exit 1
}

# Parse command-line options
while getopts "i:H:f:" opt; do
    case $opt in
        i)
            input_fasta="$OPTARG"
            ;;
        H)
            hmm_file="$OPTARG"
            ;;
        f)
            og_sequence_file="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done

# Check if the required options are provided
if [ -z "$input_fasta" ] || [ -z "$hmm_file" ] || [ -z "$og_sequence_file" ]; then
    echo "Error: All options (-i, -H, -f) must be provided."
    usage
fi

# Perform MSA for the input fasta file
perform_msa "$input_fasta" "$hmm_file" "$og_sequence_file"
