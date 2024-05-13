#!/bin/bash


## SET UP FOR INPUTS:


# Help message function
usage() {
  echo "Usage: $0 -i <input_fasta> -p <prefix> -m <email> -l <max_length>"
  echo "Data pipeline for sequences conservation analysis"
  echo "Options:"
  echo "  -i <input_fasta>: Input query fasta sequence"
  echo "  -m <email>: Valid email ex: JhonDoe@gmail.com"
  echo "  -p <prefix>: Desired name for the protein prefix. Ex: Trypsin --> tryp"
  echo "  -l <max_length>: Maximum sequence length for filtering. Default at 504"
  exit 1
}

# MAIN FUNCTION

main(){
    # Initializing default parameters
    max_length=504
    # Input arguments
    while getopts ":i:p:m:l:h" opt; do
    case $opt in
        i) input_sequence="$OPTARG" ;;
        p) prefix="$OPTARG" ;;
        m) mail="$OPTARG" ;;
        l) max_length="$OPTARG" ;;
        h) usage ;;
        \?) echo "Invalid option -$OPTARG" >&2; usage ;;
    esac
    done

    # Check if all inputs exist:
    if [[ -z "$input_sequence" || -z "$prefix" || -z "$max_length" ]]; then
    echo "Error: Missing required option(s)." >&2
    usage
    fi
    
    # Record the start time
    start_time=$(date +%s)

    # MODULE 1: IPRSCAN
    python3 functions/iprscan.py --email "$mail" --stype p --sequence "$input_sequence" --outfile "$prefix"

    # MODULE 2: INTERPRO CONNECT
    json_file_name="data/${prefix}.json.json"
    functions/interpro_connect.sh -i "$json_file_name" -o data 

    ids=$(python3 functions/json_getIDs.py -i "$json_file_name") #Getting hmm ID name locally
    protein_ID=$(echo "$ids" | awk '{print $1}')
    hmmID=$(echo "$ids" | awk '{print $2}')

    # MODULE 3: FILTERING:
    filtered_fasta_name="data/${protein_ID%.fasta}_filtered.fasta" # Output name
    functions/filter.sh -i "data/${protein_ID}_raw.fasta" -o "$filtered_fasta_name" -l "$max_length"

    # MODULE 4: CLUSTERING
    functions/clustering_c.sh -i "$filtered_fasta_name" -p "$prefix" -f "$input_sequence"  -o results/

    # MODULE 5: ALIGNMENT: 
    functions/alignment_c.sh -i results -H data/"$hmmID".hmm -p "$prefix" -f "$input_sequence"

    # MODULE 6: CONSERVATION ANALYSIS:
    functions/cons_analysis_c.sh -i results -p "$prefix"
    
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