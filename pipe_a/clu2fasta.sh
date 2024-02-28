#!/bin/bash

# Parse command-line arguments
while getopts "i:o:" opt; do
  case $opt in
    i) input_file="$OPTARG";;
    o) output_file="$OPTARG";;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
  esac
done

# Check if input file is provided
if [ -z "$input_file" ]; then
  echo "Error: Input file not specified. Use -i <input_file>" >&2
  exit 1
fi

# Check if output file is provided
if [ -z "$output_file" ]; then
  echo "Error: Output file not specified. Use -o <output_file>" >&2
  exit 1
fi

# Replace the beginning of each fasta header with ">"
sed 's/^.*>/>/' "$input_file" | sed '$d' > "$output_file"
