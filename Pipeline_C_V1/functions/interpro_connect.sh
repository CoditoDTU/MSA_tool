#!/bin/bash


# Run the first script and store its output in a variable
#output=$(python3 json_getIDs.py -i FDH_search_result.json)

# Pass the output of the first script as input to the second script
#echo "$output"

#protID=$(echo "$output" | awk '{print $1}')
#hmmID=$(echo "$output" | awk '{print $2}')

### Here new code structured


get_hmm() {
    hmm_ID=$1
    #Base url for particular pfam file
    hmm_url="https://www.ebi.ac.uk/interpro/wwwapi//entry/pfam/${hmm_ID}?annotation=hmm"
    
    hmm_compressed="data/${hmm_ID}_compressed.gz"
    hmm_file="data/${hmm_ID}.hmm"

    wget -O "$hmm_compressed" "$hmm_url" 
    gunzip -c "$hmm_compressed" > "$hmm_file"
    rm "$hmm_compressed"

}

get_fasta() {
    protein_ID=$1
    

     python3 functions/Ipr_api_downform.py -i "$protein_ID" > "data/${protein_ID}_raw.fasta"
     
}


usage() {
    echo "Usage: $0 -i <input_file> -o <output_path>"
    echo "Mandatory arguments:"
    echo "  -i <input_file>: Path to the Json files with information to extract"
    echo "  -o <output_path>: Output path for hmm and fasta files"
    exit 1
}


main() {
    # Parse command-line arguments
    while getopts ":i:o:" opt; do
        case $opt in
            i) 
                input_file="$OPTARG" 
                ;;
            o) 
                output_path="$OPTARG" 
                ;;
            \?) 
                echo "Invalid option: -$OPTARG" >&2
                exit 1 
                ;;
            :) echo "Option -$OPTARG requires an argument" >&2
                exit 1 ;;
        esac
    done

    # Check if the required options are provided
    if [ -z "$input_file" ] || [ -z "$output_path" ]; then
        echo "Error: All options ( -i, -o) must be provided."
        usage  # Display usage information if any of the required options are missing
    fi
    # START OF GENERAL FUNCTION:

    # Get IDs
    ids=$(python3 functions/json_getIDs.py -i "$input_file")
    protID=$(echo "$ids" | awk '{print $1}')
    hmmID=$(echo "$ids" | awk '{print $2}')

    # Get Fasta file
    get_hmm "$hmmID"
    get_fasta "$protID"

}




# Call the main function
main "$@"
