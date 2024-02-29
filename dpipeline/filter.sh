#!/bin/bash

# Help message function
usage() {
  echo "Usage: $0 -i <input_fasta> -o <output_fasta> -l <max_length>"
  echo "Length-based filtering script for FASTA files."
  echo "Options:"
  echo "  -i <input_fasta>: Input FASTA file to filter"
  echo "  -o <output_fasta>: Desired name for the filtered FASTA file"
  echo "  -l <max_length>: Maximum sequence length for filtering"
  exit 1
}

# Parse command-line arguments
while getopts ":i:o:l:h" opt; do
  case $opt in
    i) input_fasta="$OPTARG" ;;
    o) output_fasta="$OPTARG" ;;
    l) max_length="$OPTARG" ;;
    h) usage ;;
    \?) echo "Invalid option -$OPTARG" >&2; usage ;;
  esac
done

# Check if -h option is provided
if [[ "$1" == "-h" ]]; then
  usage
fi

# Check if required options are provided
if [[ -z "$input_fasta" || -z "$output_fasta" || -z "$max_length" ]]; then
  echo "Error: Missing required option(s)." >&2
  usage
fi

# Check if input file exists
if [[ ! -f "$input_fasta" ]]; then
  echo "Error: Input file $input_fasta does not exist."
  exit 1
fi

# Call the Python filtering function
python3 len_filt.py "$input_fasta" "$output_fasta" "$max_length"

# Length verification of the output fasta
python3 verify_lengths.py "$output_fasta"

# Check if the filtered file was generated successfully
if [[ -f "$output_fasta" ]]; then
  echo "Filtering completed successfully! Filtered sequences saved in $output_fasta"
else
  echo "Error: Filtering failed. Please check the Python script and input file."
fi
