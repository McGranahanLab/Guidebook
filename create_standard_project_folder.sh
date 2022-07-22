#!/bin/bash

# FILE: create_standard_project_folder.sh -------------------------------------
#
# DESCRIPTION: a bash script to create a standard project directory structure
#              used in McGranahan lab
# USAGE: 
#        chmod +x create_standard_project_folder.sh # make script executable
#        ./create_standard_project_folder.sh -n myTestProject
#
# OPTIONS: -n string, name for the project folder to be created
#
# EXAMPLE: first, navigate to the folder where you'd like your project folder
#          to be created. Then, run commands
#          chmod +x create_standard_project_folder.sh # make script executable
#          ./create_standard_project_folder.sh -n myTestProject
#
# REQUIREMENTS: none
# BUGS: --
# NOTES:  ---
# AUTHOR:  Maria Litovchenko, m.litovchenko@ucl.ac.uk
# COMPANY:  UCL, London, the UK
# VERSION:  1
# CREATED:  22.07.2022
# REVISION: 22.07.2022

# Step 1: get name of the future project folder -------------------------------
project_name=''
while getopts n: flag
do
    case "${flag}" in
        n) project_name=${OPTARG};;
    esac
done

if [ "$project_name" = "" ]; then
    exit "Please give project folder a name with use of -n"
fi

# working directory
cwd=`pwd`

echo "Started creation of project directory for $project_name";

# Step 2: create all the required folders -------------------------------------
mkdir -p $cwd'/'$project_name
cd $project_name

echo 'Project directory for '$project_name > README.md
echo 'data: contains RAW data used in this project' >> README.md
echo 'inventory: contains inventory tables for samples\ 
      and analysis ' >> README.md
echo 'assets: contains various static support files for the analysis, \
      i.e. reference genomes, COSMIC databases, etc' >> README.md
echo 'logs: contains messages printed by softwares' >> README.md
echo 'results: contains results of various software runs' >> README.md
echo 'papers: contains PDFs of major publications linked to this \
      analysis' >> README.md
echo 'reports: contains presentations and text reports' >> README.md

mkdir data
mkdir inventory
mkdir assets
mkdir assets/reference_genome
mkdir assets/additional_dbs
mkdir logs
mkdir results
mkdir results/plots
mkdir results/tables
mkdir papers
mkdir reports

cd $cwd

echo "Finished creation of project directory for $project_name";