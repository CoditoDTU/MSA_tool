import json
import sys
import argparse


def get_prot_IDs(data):
    protein_IDs =[]
    for n in range(len(data['results'][0]['matches'])):
        
        try:
            signature_entry_type = data['results'][0]['matches'][n]["signature"].get('entry', {}).get('type')
            if signature_entry_type == 'FAMILY':
                protein_IDs.append(data['results'][0]['matches'][n]["signature"]['entry']['accession']) # Accession gives us protein ID
        except AttributeError:
            # If 'signature' or 'entry' is not found, continue with the next iteration
            continue

    return protein_IDs


def get_hmm_IDs(json_data):
    hmm_IDs = []
    for n in range(len(json_data['results'][0]['matches'])):
        try:
            signature_library_type = json_data['results'][0]['matches'][n]["signature"]['signatureLibraryRelease'].get('library')
            if signature_library_type == 'PFAM':
                hmm_IDs.append(json_data['results'][0]['matches'][n]["signature"]['accession'])
        except AttributeError:
            # If 'signature' or 'entry' is not found, continue with the next iteration
            continue
    return hmm_IDs


def usage():
    """
    Function to display usage information.
    """
    print("Usage: json_getIDs.py -i json_file")
    print("Arguments:")
    print("  -i, --input_file: Path to the input json file")
    #print("  -o, --output_file: Path to the output fasta file")
    sys.exit(0)


def main():
    """
    Main function to parse command-line arguments and functions.
    """
    parser = argparse.ArgumentParser(description='Looks for Ids in an interpro result json file')
    parser.add_argument("-i", "--input_file", required=True, help="Input json results file")
    #parser.add_argument("-o", "--output_file")
    args = parser.parse_args()

    with open(args.input_file, 'r') as f:
        data_interpro_json = json.load(f) # Interpro json file with the prot ID and
    
    # Gets protein IDs
    protIDs = get_prot_IDs(data_interpro_json)
    # Gets Hmm IDs
    hmmIds = get_hmm_IDs(data_interpro_json)
    print(protIDs[0])
    print(hmmIds[0])

if __name__ == "__main__":
    main()