from Bio import SeqIO
import sys
import argparse

def filter_sequences(input_fasta, output_fasta, max_length):
    """Filters sequences in a FASTA file by length.

    Args:
        input_fasta (str): Path to the input FASTA file.
        output_fasta (str): Path to the output FASTA file.
        max_length (int): Maximum allowed sequence length.
    """

    filtered_sequences = []
    for record in SeqIO.parse(input_fasta, "fasta"):
        if len(record.seq) <= max_length:
            filtered_sequences.append(record)

    SeqIO.write(filtered_sequences, output_fasta, "fasta")

# Create a main function for argparse
def Main():
    parser = argparse.ArgumentParser(description = "Filter sequences in a FASTA file by length.")
    parser.add_argument('input_fasta', help = "The name of the file or path to file desired to filter",
                         type = str)
    parser.add_argument("output_fasta", help="Path to the output FASTA file.")
    parser.add_argument("max_length", type=int, help="Maximum allowed sequence length.")
    
    args = parser.parse_args()

    filter_sequences(args.input_fasta, args.output_fasta, args.max_length)

    





if __name__ == "__main__":
  Main()


   



"""
Original version without arg parse:

    # Check if the correct number of command-line arguments is provided
    if len(sys.argv) != 4:
        print("Usage: python3 len_filt.py <input_fasta> <output_fasta> <max_length>")
        sys.exit(1)

    # Get the input filename, output filename, and max length from the command-line arguments
    input_fasta = sys.argv[1]
    output_fasta = sys.argv[2]
    max_length = int(sys.argv[3])

    # Call the filter_sequences function with command-line arguments
    filter_sequences(input_fasta, output_fasta, max_length)
"""