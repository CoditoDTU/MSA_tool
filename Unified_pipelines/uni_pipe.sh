#!/bin/bash

# Help message function
usage() {
  echo "Usage: $0 -i <input_fasta> -p <prefix> -m <email> -l <max_length>"
  echo "Data pipeline for sequences conservation analysis"
  echo "Options:"
  echo "  -i <input_fasta>: Input query fasta sequence"
  echo "  -m <email>: Valid email ex: JhonDoe@gmail.com"
  echo "  -p <prefix>: Desired name for the protein prefix. Ex: Trypsin --> tryp"
  echo "  -l <max_length>: Maximum sequence length for filtering. Default at 504"
  echo "  -t <pipeline to execute>: Select which pipeline to use if A,B and C"
  echo "  -o <Output directory>: Select where your results should go"
  exit 1
}

main(){
    # Initializing default parameters
    max_length=504
    # Input arguments
    while getopts ":i:p:m:l:o:t:h" opt; do
    case $opt in
        i) input_sequence="$OPTARG" ;;
        p) prefix="$OPTARG" ;;
        m) mail="$OPTARG" ;;
        l) max_length="$OPTARG" ;;
        o) output_folder="$OPTARG" ;;
        t) pipeline="$OPTARG" ;;
        h) usage ;;
        \?) echo "Invalid option -$OPTARG" >&2; usage ;;
    esac
    done

    # Check if all inputs exist:
    if [[ -z "$input_sequence" || -z "$prefix" || -z "$max_length" || -z "$pipeline" || -z "$output_folder" ]]; then
    echo "Error: Missing required option(s)." >&2
    usage
    fi

    # Record the start time
    start_time=$(date +%s)

    if  [ "$pipeline" = "a" ]; then
        ./pipeline_A.sh -i "$input_sequence" -m "$mail" -p "$prefix" -l "$max_length" -o "$output_folder"
    
    elif [ "$pipeline" = "b" ]; then
        ./pipeline_B.sh -i "$input_sequence" -m "$mail" -p "$prefix" -l "$max_length" -o "$output_folder"

    elif [ "$pipeline" = "c" ]; then
        ./pipeline_C.sh -i "$input_sequence" -m "$mail" -p "$prefix" -l "$max_length" -o "$output_folder"
    fi



    # Record the end time
    end_time=$(date +%s)

    # Calculate the elapsed time in seconds
    elapsed_time=$((end_time - start_time))

    # Convert elapsed time from seconds to minutes
    elapsed_minutes=$((elapsed_time / 60))
    
    # Print the elapsed time in minutes
    echo "Elapsed time: $elapsed_minutes minutes"
}

# EXECUTION

# Call the main function
main "$@"