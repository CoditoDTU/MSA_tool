import sys
from Bio import SeqIO
import argparse

def add_header(input_file, output_file, header_file):
    """
    Function to add a header sequence to a fasta file if it's missing.

    Parameters:
        input_file (str): Path to the cluster file to check
        output_file (str): Path to the output fasta file = New file with sequence added
        header_file (str): Path to the fasta file containing Original querie sequence
    """
    # Read the header sequence from the header file
    header_record = SeqIO.read(header_file, "fasta")

    # Check if the header exists in the input file
    header_exists = False
    for record in SeqIO.parse(input_file, "fasta"):
        if record.description == header_record.description:
            header_exists = True
            # Check if the sequence matches as well
            if str(record.seq) == str(header_record.seq):
                print("Header and sequence already present in the input file.")
            else:
                print("Header found in the input file, but with a different sequence.")
            break

    # If header doesn't exist, add it to the beginning of the file
    if not header_exists:
        SeqIO.write(header_record, output_file, "fasta")
        with open(input_file, "r") as f:
            with open(output_file, "a") as f_out:
                for line in f:
                    f_out.write(line)

def usage():
    """
    Function to display usage information.
    """
    print("Usage: python script.py -i input_file -o output_file -f header_file")
    print("Arguments:")
    print("  -i, --input_file: Path to the input fasta file")
    print("  -o, --output_file: Path to the output fasta file")
    print("  -f, --header_file: Path to the fasta file containing the header sequence")
    sys.exit(0)

def main():
    """
    Main function to parse command-line arguments and call the add_header function.
    """
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description='Add header if missing')
    parser.add_argument("-i", "--input_file", required=True, help='Input fasta file')
    parser.add_argument("-o", "--output_file", required=True, help='Output fasta file')
    parser.add_argument("-f", "--header_file", required=True, help='Header sequence fasta file')
    args = parser.parse_args()

    # Call the add_header function
    add_header(args.input_file, args.output_file, args.header_file)

if __name__ == "__main__":
    main()
