from Bio import SeqIO
import argparse
def verify_lengths(fasta_file, max_length=504):
    """Verifies that all sequences in a FASTA file are under a specified maximum length.

    Args:
        fasta_file (str): Path to the FASTA file to verify.
        max_length (int, optional): Maximum allowed sequence length. Defaults to 504.

    Returns:
        bool: True if all sequences are under the maximum length, False otherwise.
    """

    all_sequences_valid = True
    with open(fasta_file, "r") as handle:
        for record in SeqIO.parse(handle, "fasta"):
            if len(record.seq) > max_length:
                print(f"Sequence {record.id} exceeds maximum length ({len(record.seq)} > {max_length}).")
                all_sequences_valid = False

    if all_sequences_valid:
        print("All sequences in the FASTA file are within the specified length limit.")
    else:
        print("Some sequences in the FASTA file exceed the specified length limit.")

    return all_sequences_valid

def main():

    parser = argparse.ArgumentParser(description = 
                        "Verify that sequences in a FASTA file are under a specified maximum length.")
    parser.add_argument("fasta_file", help="Path to the FASTA file to verify.")
    parser.add_argument("--max_length", type=int, default=504, help="Maximum allowed sequence length. Defaults to 504.")
    args = parser.parse_args()

    verify_lengths(args.fasta_file, args.max_length)
