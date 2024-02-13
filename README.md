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

# Python & .sh modules(Work in progress)


### Running bash scripts
While trying to run bash scripts your equipment may not run without the proper activation of the files. Therefore, in order to make them executable follow the next commands:

```
chmod u+x your_bash_file.sh # Makes the file executable
./your_bash_file.sh <PLACEHOLDER_ARGUMENTS> # Runs the executable .sh files
```

## Filter module(filter sh)