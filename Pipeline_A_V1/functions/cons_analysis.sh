#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -i <folder_path> -p <prefix>"
    echo "Options:"
    echo "  -i <folder_path>: Path to the folder containing the input files"
    echo "  -p <prefix>: Prefix for file matching"
    exit 1
}

# Initialize variables
prefix="tryp"  # Default prefix

# Parse command-line options
while getopts ":i:p:" opt; do
    case $opt in
        i)
            folder_path="$OPTARG"   # Store the provided folder path
            ;;
        p)
            prefix="$OPTARG"   # Store the provided prefix
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage  # Display usage information if an invalid option is provided
            ;;
    esac
done

# Check if the folder path is provided
if [ -z "$folder_path" ]; then
    echo "Error: Folder path (-i) must be provided."
    usage  # Display usage information if the folder path is missing
fi

# Loop through each file in the folder with the specified prefix
for file in "$folder_path"/"${prefix}"_clu_seq*_og_aligned.fasta; do
    # Check if the file exists
    if [ -f "$file" ]; then
        # Extract cluster number from the filename
        cluster_number=$(echo "$file" | grep -oP "(?<=${prefix}_clu_seq)[0-9]+")

        # Run the Python script for the current file
        python3 functions/conserved_seq.py -i "$file" -o "$folder_path/${prefix}_clu_${cluster_number}_A_cs.csv"

        echo "Conservation analysis executed for $file"
    else
        echo "File $file does not exist"
    fi
done
