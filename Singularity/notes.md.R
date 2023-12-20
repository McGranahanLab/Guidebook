
Helping you to get on top of your bioinformatics game with 
Technical details should not be inpeading to great research.

Bootstrap: docker
From: ubuntu:14.04

Bootstrap: docker
From: ubuntu:18.04

Bootstrap: docker
From: ubuntu:20.04

Bootstrap: docker
From: continuumio/anaconda2

Bootstrap: docker
From: continuumio/miniconda2

Bootstrap: docker
From: continuumio/anaconda3

Bootstrap: docker
From: continuumio/miniconda3

Bootstrap: docker
From: julia:1.3

Bootstrap: docker
From: rstudio/r-base:4.0-focal

Bootstrap: docker
From: ibmjava

Bootstrap: docker
From: ubuntu:20.04

%post
# 
apt-get update
apt-get upgrade -y

# Here we are located in the root of the system. Avaible folders are:
export DEBIAN_FRONTEND=noninteractive

# Step 1: installation of basic libraries
apt-get install -y wget curl \
unzip zip bzip2 tabix \
git \
gfortran perl \
gcc g++ make cmake build-essential \
software-properties-common \
autoconf \
ca-certificates

wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2
apt-get install -qq -y libncurses5-dev zlib1g-dev libbz2-dev liblzma-dev
tar -xf samtools-1.10.tar.bz2
cd samtools-1.10
./configure
make
make install
cd ../
  
  mkdir tiny_scripts
echo '#!/bin/bash' > tiny_scripts/say_cheese.sh
echo 'echo CHEESE!' >> tiny_scripts/say_cheese.sh

%environment
export PATH=$PATH:/samtools-1.10/bin:$PATH
PI=3.14

%test
samtools --help

%labels
CREATOR     Maria Litovchenko
ORGANIZATION    TEST_WORKING_PLACE       
EMAIL
VERSION v0.0.1    

%help
Main software:
  samtools        v.1.10          http://www.htslib.org/
  
  Example run:
  singularity exec samtools_in_a_box.sif samtools --help





## Java
## Julia
## How to use container from docker as a base and why not to do it.

## Sandbox container creation
why I don't reccomend building based on other people's docker containers: they change! Especially something latest.

## Can I modify already created container? YES! Should I? NO!
