import argparse
from Bio import AlignIO
from Bio.Align import AlignInfo
import pandas as pd

def calculate_conservation(msa_file):
    """
    Calculates the percentage of conservation of each residue from the first sequence in the alignment across all sequences in the MSA, excluding gaps.

    Parameters:
        msa_file (str): Path to the input MSA file (in FASTA format).

    Returns:
        pandas.DataFrame: DataFrame containing the position, conserved residue, and percentage conservation of each residue.
    """
    # Read the MSA file
    alignment = AlignIO.read(msa_file, "fasta")

    # Get the first sequence (original sequence)
    original_seq = str(alignment[0].seq)

    # Create an AlignInfo summary object
    summary = AlignInfo.SummaryInfo(alignment)

    # Get the length of the alignment
    alignment_length = alignment.get_alignment_length()

    # Initialize lists to store conservation values
    positions = []
    conserved_residues = []
    conservation_values = []

    # Iterate over each position in the alignment
    for pos in range(alignment_length):
        # Skip if the position in the original sequence is a gap
        if original_seq[pos] == "-":
            continue
        
        # Count occurrences of each residue at the current position
        residue_counts = {}
        for record in alignment:
            residue = record.seq[pos]
            if residue == "-":
                continue
            if residue in residue_counts:
                residue_counts[residue] += 1
            else:
                residue_counts[residue] = 1
        
        # Calculate conservation for the current position
        original_residue = original_seq[pos]
        if original_residue in residue_counts:
            conservation = residue_counts[original_residue] / len(alignment)
        else:
            conservation = 0
        
        # Add conserved residue information to lists
        positions.append(pos + 1)  # Convert to 1-based indexing
        conserved_residues.append(original_residue)
        conservation_values.append(conservation)
    
    # Create DataFrame
    #df_conservation = pd.DataFrame({'Position': positions, 'Conserved Residue': conserved_residues, 'Conservation': conservation_values})
    df_conservation = pd.DataFrame({'Conserved Residue': conserved_residues, 'Conservation': conservation_values})
    return df_conservation

def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Calculate conservation of residues from the first sequence in the alignment")
    parser.add_argument("-i", "--input", required=True, help="Input MSA file (in FASTA format)")
    parser.add_argument("-o", "--output", required=True, help="Output file path")
    args = parser.parse_args()

    # Calculate conservation
    df_conservation = calculate_conservation(args.input)
    
    # Save the DataFrame to the output file path
    df_conservation.to_csv(args.output, sep=',', index=False)

if __name__ == "__main__":
    main()