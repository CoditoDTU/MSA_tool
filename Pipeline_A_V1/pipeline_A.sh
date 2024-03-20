#!/bin/bash


## SET UP FOR INPUTS:


# Help message function
usage() {
  echo "Usage: $0 -i <input_fasta> -o <output_fasta> -l <max_length>"
  echo "Length-based filtering script for FASTA files."
  echo "Options:"
  echo "  -i <input_fasta>: Input query fasta sequence"
  echo "  -p <prefix>: Desired name for the protein prefix. Ex: Trypsin --> tryp"
  echo "  -l <max_length>: Maximum sequence length for filtering. Default at 504"
  exit 1
}

# MODULE 1: Iprscan5
Interpro_scan(){
    query_sequence=$1

}
# MODULE 2: Interpro connect

Interpro_connection(){
    json_file=$1
}

# MODULE 3: Filtering

Filtering(){
    local raw_fasta=$1
    local filtering_length=$2
    local raw_fasta_name="${raw_fasta%.fasta}"
    
    functions/filter.sh -i "$raw_fasta" -o "${raw_fasta_name}_filtered.fasta" -l "$filtering_length"
}

# MODULE 4: Clustering

Clustering(){
    filtered_fasta=$1
    protein_prefix=$2
}

# MODULE 5: Alignment

Alignment_A(){
    path_to_clusters=$1
    protein_prefix=$2
    hmm_file=$3
    og_sequence_file=$4
}


# MAIN FUNCTION

main(){
    # Input arguments
    while getopts ":i:p:l:h" opt; do
    case $opt in
        i) input_sequence="$OPTARG" ;;
        p) prefix="$OPTARG" ;;
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


    # MODULE 1: IPRSCAN
    echo python3 functions/iprscan.py --email rogall@dtu.dk --stype p --sequence "$input_sequence" --outfile "$prefix"

    # MODULE 2: INTERPRO CONNECT
    json_file_name="data/${prefix}.json.json"
    echo functions/interpro_connect.sh -i "$json_file_name" -o data 

    ids=$(python3 functions/json_getIDs.py -i "$json_file_name") #Getting hmm ID name locally
    protein_ID=$(echo "$ids" | awk '{print $1}')
    hmmID=$(echo "$ids" | awk '{print $2}')

    # MODULE 3: FILTERING:
    filtered_fasta_name="data/${protein_ID%.fasta}_filtered.fasta" # Output name
    echo "$filtered_fasta_name"
    functions/filter.sh -i "data/${protein_ID}_raw.fasta" -o "$filtered_fasta_name" -l "$max_length"

    # MODULE 4: CLUSTERING
    functions/clustering_A.sh -i "$filtered_fasta_name" -p "$prefix" -o results

    # MODULE 5: ALIGNMENT: 
    functions/alignment_a.sh -i results -H data/"$hmmID".hmm -p "$prefix" -f "$input_sequence"

    # MODULE 6: CONSERVATION ANALYSIS:
    functions/cons_analysis.sh -i results -p "$prefix"

}



# EXECUTION

# Call the main function
main "$@"