#!/bin/bash
clustering() {
    local prefix="test"
    local input_file=""
    local output_path="."

    #Usage function for help
    usage() {
        echo "Usage: $0 [-p <prefix>] [-i <input_file>] [-o <output_path>]"
        echo "Options:"
        echo "  -p <prefix>        Specify a prefix for the output files (default: gb1)"
        echo "  -i <input_file>    Specify the input FASTA file"
        echo "  -o <output_path>   Specify the output location with a path (default: current directory)"
        exit 1
    }
    
    #Parse command line options

    while getopts ":p:i:o:h" opt; do
        case ${opt} in
            p )
                prefix="$OPTARG"
                ;;
            i ) 
                input_file="$OPTARG"
                ;;
            o )
                output_path="$OPTARG"
                ;;
            h ) 
                usage
                ;;
            \? )
                echo "Invalid option: $OPTARG" 1>&2 # Redirects to the standar erros stream instead of the stdout
                exit 1
                ;;
            : )
                echo "Invalid option: $OPTARG requires an argument" 1>&2
                exit 1
                ;;
        esac
    done
    shift $((OPTIND -1)) # what is this?

    # Check if input file is provided
    if [ -z "$input_file" ]; then
        echo "Error: Input file is required" 1>&2
        usage
    fi 

    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' not found" 1>&2 
        exit 1
    fi

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
    mmseqs createseqfiledb "$tmp_dir/${prefix}_DB" "$tmp_dir/${prefix}_clu" "$output_path/${prefix}_clu_seq"

    #clean tmp dir
    rm -rf "$tmp_dir"
}

clustering "$@"