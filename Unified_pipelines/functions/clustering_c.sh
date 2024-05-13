#!/bin/bash

# Function to add the original sequence to the input FASTA file
add_original_sequence() {
    input_file="$1"          # Input FASTA file
    og_sequence="$2"         # Original sequence file
    temp_input_file="$3"     # Temporary copy of the original FASTA file

    # Call Python script to add OG sequence
    python3 functions/add_ogseq.py -i "$input_file" -o "$temp_input_file" -f "$og_sequence"

    # Remove the original input file
    #rm "$input_file"
}

# Function to cluster the input FASTA file
cluster_sequences() {
    input_file="$1"  # Input FASTA file
    prefix="$2"      # Prefix for output files
    output_path="$3"    # HMM file for clustering

    # Create temp directory for intermediate files
    local tmp_dir
    tmp_dir=$(mktemp -d mmseqs_tmp.XXXXXX) # why the XXX
    
    # Trap to clean up temporary files on exit
    trap rm -rf "$tmp_dir" EXIT
    
    # Main functionality

    # Fasta -> MMseqs2 DB
     mmseqs createdb "$input_file" "$tmp_dir/${prefix}_DB"

    # Cluster sequences
     mmseqs cluster "$tmp_dir/${prefix}_DB" "$tmp_dir/${prefix}_clu" "$tmp_dir" --min-seq-id 0.7

    # Create sequence files from clusters
     mmseqs createseqfiledb "$tmp_dir/${prefix}_DB" "$tmp_dir/${prefix}_clu" "$output_path${prefix}_clu_seq"

    #clean tmp dir
    rm -rf "$tmp_dir"
}



# Main function
main() {
    # Parse command-line arguments
    while getopts ":i:o:p:f:" opt; do
        case $opt in
            i) 
                input_file="$OPTARG" 
                ;;
            o) 
                output_path="$OPTARG" 
                ;;
            p) 
                prefix="$OPTARG" 
                ;;
            f) 
                og_sequence="$OPTARG" 
                ;;
            \?) 
                echo "Invalid option: -$OPTARG" >&2
                exit 1 
                ;;
            :) echo "Option -$OPTARG requires an argument" >&2
                exit 1 ;;
        esac
    done

    # Set temporary input file
    input_withOG="${input_file%.fasta}_og.fasta"

    # Add the original sequence to the input FASTA file
    add_original_sequence "$input_file" "$og_sequence" "$input_withOG"

    # Cluster the input FASTA file
    cluster_sequences "$input_withOG" "$prefix" "$output_path"

    # Convert clustered sequence files to FASTA format
    #convert_to_fasta "results"  # Assuming clustered files are stored in "results" directory

}

# Call the main function
main "$@"
