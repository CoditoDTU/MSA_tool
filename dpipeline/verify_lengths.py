from Bio import SeqIO

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