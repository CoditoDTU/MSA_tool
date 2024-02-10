import argparse
from Bio import AlignIO
from Bio.Align import AlignInfo
import numpy as np
from Bio import SeqIO

def get_conserved_sites(msa_file, threshold):
    
    # Read the MSA file
    alignment = AlignIO.read(msa_file, "fasta")

    # Create an AlignInfo summary object
    summary = AlignInfo.SummaryInfo(alignment) # obtains results from the aligment object created before

    # Calculate the conservation of each position in the aln
    conservation = summary.pos_specific_score_matrix()

    # Get the length of the Alignment(Positions length)
    aln_len = alignment.get_alignment_length()

    # Get number of sequences for threshold
    sequence_number = len(alignment)

    # Calculate conservation threshold
    thres_val = threshold * sequence_number # number of ocurrences needed to reach the threshold ex: 0.7*100 = 70 ocurrences threshold

    # Extract conserved sites
    conserved_pos = [] #positions
    conserved_keys = [] #AA letter
    conserved_prob = [] # %of conservation Ex: 0.7 = 7/10
    '''
    for position in conservation:
        if conservation[position] >= thres_val:
            conserved_sites.append(position + 1) # Convert to 1-based indexing
    
    #return conserved_sites
    ''' 
    for i in range(aln_len):
        max_conservation = max(conservation[i].values()) # Most present amino acid in each position number 
        max_key = max(conservation[i], key = conservation[i].get) # Gets letter from the most present aminoacid in position
        if max_conservation >= thres_val:
            conserved_pos.append(i+1) # Convert to 1-based indexing
            conserved_keys.append(max_key)
            conserved_prob.append(max_conservation/sequence_number) # returning it as a %

    results = np.array([conserved_keys, conserved_pos, conserved_prob]).T
    return results



def map_conserved_sites(original_fasta_file, conserved_sites, msa_file):
    # Read the original FASTA file
    sequences = SeqIO.to_dict(SeqIO.parse(original_fasta_file, "fasta"))

    # Find the first sequence dynamically
    first_sequence_name = next(iter(sequences))

    # Convert first sequence to string
    seq1 = str(sequences[first_sequence_name].seq)

    # Read the MSA file to count gaps in the first sequence
    with open(msa_file, 'r') as f:
        msa_record = next(SeqIO.parse(f, 'fasta'))
        msa_seq1 = str(msa_record.seq)

   # Convert position from conserved_sites to an integer
    last_conserved_pos = int(conserved_sites[-1][1]) #[-1]: This accesses the last element in the list  [1]: This accesses the second element of the inner list, which corresponds to the position of the conserved site.

    # Count gaps in the first sequence of the MSA

    gap_count = msa_seq1[:last_conserved_pos].count('-')

    # Initialize list to store mapped conserved sites
    mapped_conserved_sites = []

    # Map conserved sites to the original sequence
    for conserved_site in conserved_sites:
        conserved_aa, conserved_pos, conserved_prob = conserved_site
        conserved_pos = int(conserved_pos)

        # Adjust the position based on the number of gaps
        mapped_pos = conserved_pos - gap_count

        # Append mapped conserved site to the list
        mapped_conserved_sites.append([conserved_aa, mapped_pos, conserved_prob])

    return mapped_conserved_sites



def main():
    
    #Argument parser
    parser = argparse.ArgumentParser(description = "Extract conserved regions from MSA file")
    parser.add_argument("-i", "--input", required = True, help  = "Input MSA file (in FASTA format)")
    parser.add_argument("-t", "--threshold", required = True, type = float, help = "Conservation threshold (between 0 and 1)")
    parser.add_argument("-f", "--fasta", required = True,  help = "Original fasta file before the MSA")
    
    args = parser.parse_args()

    # Function is then called
    conserved_sites = get_conserved_sites(args.input, args.threshold)
    conserved_sites_os = map_conserved_sites(args.fasta, conserved_sites, args.input)
    print("There are", len(conserved_sites), "conserved aminoacids with a threshold of", args.threshold,":")
    print(conserved_sites)
    print(conserved_sites_os)

if __name__ == "__main__":
    main()

# Comments from 07/02:
# Calculate amount of sequences first to know how many there are as the matrix does not contain that 
# High priority : Calculate position in the og sequence of the conserved 
# Report the position and the AA from that particular sequence