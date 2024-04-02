# MSA tool for Proteus AI

Hello! This is the MSA_tool project, where I will be developing the MSA module for the
ProteusAI tool developed by [@Jonfunk21](https://github.com/jonfunk21/ProteusAI). The purpose of this project is to design a data pipeline for producing MSA's. This program should recieve as Input a FASTA protein file and outputs an MSA with its respective family protein ID and which conerved residues from this MSA are conserved within the input.

## Supported OS(Operating Systems)
This MSA tool has been tested using Ubuntu 22.04 and MacOS 10.13.6 High sierra. It should therfore work in any linux-based system that has Python installed(Normally built in).

## Dependencies 
* Python >= 3.8

(older versions may work but have not been tested)

## Installation
It is recommended that for proper use or installation of the MSA tool Conda is installed and set up a conda environment using the .yml file.

### Conda 
Conda is an open-source package management and environment system which allows easy install, run and update software packages and their respective dependencies. Mini conda is the Conda installer recommended and the one used for this project. Follow the installation instruction in their webpage [here](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) 


### Creating Conda environment

To create a new Conda environment open your terminal and first download the repository and enter the project:

```
git clone https://github.com/CoditoDTU/MSA_tool
cd path/to/MSA_tool
```

Afterwards, you can create the Conda environment using the environment.yml file which has every package and dependency you need. The name of the environment created will be "msa_tool".

```
conda env create -f environment.yml 
conda activate msa_tool
```
To check wether you are in the correct environment you can use the following command:

```
conda env list
```
This will show you the list of all your environments and show you which are you currently using denoted by an (*).

# Running the pipeline
After downloading the project in order to run the pipeline you need to do the following:


```
cd Pipeline_A_V1/ # Enters the executable pipeline

./pipeline_A.sh -i path/to/your/fastaFile -p prefix -l filering lenght(number)
```
An example of the pipeline running would look something like this:
```
./pipeline_A.sh -i Trypsin_sequence.fasta -p tryp -l 500
```
## Getting the results
Results are kept into the "results/" folder so:
```
cd results/
```
There, you can find the .csv files which correspond to the Conservation analaysis for the initial submitted sequence

## Interpreting the results:
The results will look like the following table:

|Conserved Residue|Conservation                 |
|-----------------|-----------------------------|
|M                |0.027796610169491524         |
|A                |0.01288135593220339          |
|S                |0.06644067796610169          |
|V                |0.03593220338983051          |
|H                |0.0047457627118644066        |
|G                |0.002711864406779661         |
|T                |0.005423728813559322         |
|T                |0.003389830508474576         |
|Y                |0.002033898305084746         |
|E                |0.11254237288135593          |
|L                |0.017627118644067796         |
|L                |0.3891525423728814           |

#### Column 1 - Residue from Query Protein Sequence:
  Each row in the first column represents a residue from the original query protein sequence.

#### Column 2 - Percentage of Conservation:
  The second column indicates the percentage(In decimal notation) of conservation for each residue throughout the multiple sequence alignment (MSA). This percentage represents the level of similarity of each residue across all sequences belonging to its respective protein family.

#### Example:
 If working with a trypsin, these results would represent the % of conservation from each residue your trypsin has with all Trypsins in the InterPro Database.


# Python & .sh modules(Work in progress)


### Running bash scripts
While trying to run bash scripts your equipment may not run without the proper activation of the files. Therefore, in order to make them executable follow the next commands:

```
chmod u+x your_bash_file.sh # Makes the file executable
./your_bash_file.sh <PLACEHOLDER_ARGUMENTS> # Runs the executable .sh files
```

## Filter module(filter.sh)