import argparse
from Bio import SeqIO

def add_sequence(input_file, output_file, header_file):
    """
    Function to add a sequence from a header file to a FASTA file if it's missing.

    Parameters:
        input_file (str): Path to the FASTA file to check.
        output_file (str): Path to the output FASTA file with sequence added.
        header_file (str): Path to the FASTA file containing the sequence to add.
    """
    # Read the sequence from the header file
    header_record = SeqIO.read(header_file, "fasta")

    # Check if the sequence exists in the input file
    sequence_exists = False
    for record in SeqIO.parse(input_file, "fasta"):
        if record.seq == header_record.seq:
            sequence_exists = True
            break

    # If sequence exists, add it to the beginning and remove its other instance
    if sequence_exists:
        # Read the input file into a list of SeqRecords
        records = list(SeqIO.parse(input_file, "fasta"))

        # Find the index of the first occurrence of the sequence in the input file
        index = next((i for i, record in enumerate(records) if record.seq == header_record.seq), None)

        if index is not None:
            # Remove the sequence from its original position
            records.pop(index)
            
            # Insert the sequence at the beginning
            records.insert(0, header_record)

            # Write the modified records to the output file
            with open(output_file, "w") as f_out:
                SeqIO.write(records, f_out, "fasta")
    else:
        print("Sequence not found in the input file.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Add a sequence from a header file to a FASTA file if it's missing.")
    parser.add_argument("-i", "--input_file", required=True, help="Path to the input FASTA file to check")
    parser.add_argument("-o", "--output_file", required=True, help="Path to the output FASTA file with sequence added")
    parser.add_argument("-f", "--header_file", required=True, help="Path to the FASTA file containing the sequence to add")
    args = parser.parse_args()

    add_sequence(args.input_file, args.output_file, args.header_file)
