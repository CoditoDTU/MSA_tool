#!/bin/bash

# Ask for input  file name
read -r -p "Enter the name of the FASTA file to filter: " input_fasta

# Check if files exist
if [[ ! -f "$input_fasta" ]]; then
  echo "Error: Input file $input_fasta does not exist."
  exit 1
fi

# Ask for  output file names
read -r -p "Enter the desired name for the filtered FASTA file: " output_fasta

# Ask for maximum sequence length
read -r -p "Enter the desired filtering sequence length: " max_length

# Call the Python filtering function
python3 len_filt.py "$input_fasta" "$output_fasta" "$max_length" # Change name of .py function 

# length verification of the output fasta
python3 verify_lengths.py "$output_fasta"  # Assuming the filtered file is in $output_fasta

# Check if the filtered file was generated successfully
if [[ -f "$output_fasta" ]]; then
  echo "Filtering completed successfully! Filtered sequences saved in $output_fasta"
else
  echo "Error: Filtering failed. Please check the Python script and input file."
fi