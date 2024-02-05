#!/bin/bash

# Create a temporary directory with a clear name
tmp_dir=$(mktemp -d mmseqs_tmp.XXXXXX)

# Trap to clean up temporary files on exit
trap 'rm -rf "$tmp_dir"' EXIT

# Convert FASTA to MMseqs2 database
mmseqs createdb gb1.fasta gb1_DB

# Cluster sequences
mmseqs cluster gb1_DB gb1_clu "$tmp_dir" --min-seq-id 0.7

# Create sequence files from clusters
mmseqs createseqfiledb gb1_DB gb1_clu gb1_clu_seq

# Move desired output files from the temporary directory (if needed)
mv "$tmp_dir/required_output_file" .  # Replace with actual file names
mv "$tmp_dir/another_output_file" .

# Clean up any remaining temporary files (optional)
rm -rf "$tmp_dir"