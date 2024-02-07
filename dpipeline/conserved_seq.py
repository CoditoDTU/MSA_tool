import argparse
from Bio import AlignIO
from Bio.Align import AlignInfo

def get_conserved_sites(msa_file, threshold):
    
    # Read the MSA file
    alignment = AlignIO.read(msa_file, "fasta")

    # Create an AlignInfo summary object
    summary = AlignInfo.SummaryInfo(alignment) # obtains results from the aligment object created before

    # Calculate the conservation of each position in the aln
    conservation = summary.pos_specific_score_matrix()

    # Get the length of the Alignment
    aln_len = alignment.get_alignment_length()

    # Calculate conservation threshold
    thres_val = threshold * aln_len

    # Extract conserved sites
    conserved_sites = []
    '''
    for position in conservation:
        if conservation[position] >= thres_val:
            conserved_sites.append(position + 1) # Convert to 1-based indexing
    
    #return conserved_sites
    ''' 
    for i in range(aln_len):
        max_conservation = max(conservation[i].values())
        if max_conservation >= thres_val:
            conserved_sites.append(i + 1)  # Convert to 1-based indexing

    return conserved_sites

def main():
    
    #Argument parser
    parser = argparse.ArgumentParser(description = "Extract conserved regions from MSA file")
    parser.add_argument("-i", "--input", required = True, help  = "Input MSA file (in FASTA format)")
    parser.add_argument("-t", "--threshold", required = True, type = float, help = "Conservation threshold (between 0 and 1)")
    
    args = parser.parse_args()

    # Function is then called
    conserved_sites = get_conserved_sites(args.input, args.threshold)
    print("Conserved sites:", conserved_sites)

if __name__ == "__main__":
    main()


# High priority : Calculate position in the og sequence of the conserved 
# Report the position and the AA from that particular sequence