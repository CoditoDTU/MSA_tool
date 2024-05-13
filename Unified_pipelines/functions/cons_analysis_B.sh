#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -i <folder_path> -p <prefix>"
    echo "Options:"
    echo "  -i <MSA_file>: MSA file to be analyzed"
    echo "  -p <prefix>: Prefix for file matching"
    echo "  -o <outputfolder>: Path of output directory of choice WITHOUT / at the end"
    exit 1
}

# Initialize variables
prefix="tryp"  # Default prefix

# Parse command-line options
while getopts ":i:p:o:" opt; do
    case $opt in
        i)
            msa_file="$OPTARG"   
            ;;
        p)
            prefix="$OPTARG"   
            ;;
        o)
            outputfolder="$OPTARG"   
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage  # Display usage information if an invalid option is provided
            ;;
    esac
done

# Check if the MSA_file is provided
if [ -z "$msa_file" ]; then
    echo "Error: MSA file (-i) must be provided."
    usage  # Display usage information if the folder path is missing
fi

python3 functions/conserved_seq.py -i "$msa_file" -o "$outputfolder/${prefix}_cs_B.csv"

