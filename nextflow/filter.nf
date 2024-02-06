#!/usr/bin/env nextflow

// Prompt user for input FASTA file
inputFasta_ch = Channel.fromPath(prompt: "Enter the path to the input FASTA file: ")

// Prompt user for output FASTA file
outputFasta_ch = Channel.fromPath(prompt: "Enter the desired path for the filtered FASTA file: ")

// Prompt user for maximum sequence length
maxLength_ch = Channel.from(
    prompt: "Enter the desired filtering sequence length: ",
    val: { it.toInteger() }
)

// Define a process to filter sequences using the first Python script
process filterSequences {
    input:
    file(inputFasta) from inputFasta_ch
    val(maxLength) from maxLength_ch
    output:
    file(outputFasta) into filteredFasta

    script:
    """
    python3 len_filt.py "$inputFasta" "$outputFasta" ${maxLength}
    """
}

// Define a process to verify sequence lengths using the second Python script
process verifyLengths {
    input:
    file(filteredFasta)

    script:
    """
    python3 verify_lengths.py "${filteredFasta}"
    """
}

// Define workflow execution
workflow {
    // Execute sequence filtering process
    filterSequences

    // Execute sequence length verification process after filtering
    verifyLengths
}
