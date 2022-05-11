# Anatomy of Singularity's recipy

## What is Singularity?
Singularity[LINK!] is a program which packages (aka *containerization*) almost any software in a file and therefore makes it **portable** and **reproducible**. 
- Portability means that a file with a software can be copied to *any* computer, server, workstation, HPC, *etc* and stay the same.
- Reproducibility means that given a singularity container with a software, results of that software execution on *any* computer, server, workstation, HPC, will stay *exactly* the same. 

## Why use Singularity (especially as bioinformatician)?
1. **Reproducibility**. It's a common knowledge that sometimes results of a software execution are highly dependable on software versions (in the field of bioinformatics especially, but not exclusive). Despite that exact software versions may be noted in the methods, some users may have difficulties retrieving or installing it. Containers solve this issue effortlessly as a future user can just download a container, exactly the same one you performed your analysis with, and run it of their data. So, if done right, containers are the road to **ultimate reproducibility**.
2. **No installation hustle**. With Singularity containers there is no struggles with software installation and version management. Containers are good to go a second after a download or creation. Need to test other software version? No problem! Just switch to another container, no need to worry about compatibility of various version on a computer/server/HPC. Containers also make you less dependent on cluster support team if you work on HPC as you won't need to bother them every time you project takes a need turn and you need to use yet another software.

## What is a Singularity container?
Container is like a light, which has properties of both a wave and a particle: container can be viewed as a file, a software and a whole remote computer. 

- Like a **file**, a container can be moved from folder to folder, copied, deleted, downloaded, uploaded, encrypted, *etc*.
- Like a **software**, a container harbors inside it a code which can be used to analyse data.
- Like a **remote computer**, a container has inside it a whole operating system (OS), i.e. Ubuntu. As to a remote server, it is possible to log in *into it* and interact with the installed software *inside* it.

## What is a recipy aka definition file?
It is written in bash.
## Recipy skeleton
Example of the simplest definition file (singularity recipe):
```
Bootstrap: docker
From: ubuntu:20.04

%post
    apt-get -y update && apt-get install -y python

%runscript
    python -c 'print("Hello World! Hello from our custom Singularity image!")'

```

In general, Singularity definition file can be divided into 2 main parts: 
**header** and **sections**. 

### Header Section
* **Header** part is usually composed out of 2 lines with which recipe starts. 
In the example above it is `Bootstrap: docker` and `From: ubuntu:20.04`. 
`Bootstrap` and `From` here are key words, like name of parameters, and 
`docker` and `ubuntu:20.04` are the values for those parameters. The recipe 
should always start from the `Bootstrap:` key word. Header of the recipe 
determines the operation system for the future container, which in turn 
controls what will already be pre-installed in the container without need for 
our intervention. In 99.9% of the cases line `Bootstrap: docker` will be the 
first line of your recipy. It says that the base OS (determined by `From:` line) will be pulled (downloaded) from Docker Hub. You can also put `Bootstrap: library`, and then the base OS will be pulled from Singularity Hub. In the majority of the cases, they are interchangeable. There are more various values you can give to `Bootstrap:`, you can read about them [](here). The `From: ` line is quite powerful. Ordinary `From: ubuntu:20.04` tells Singularity engine that you'd like to use "naked" Ubuntu v20.04 as a basis of your container, meaning that there will be nothing else installed. However, we can change value `ubuntu:20.04` to something else to allow some weight being lifted for us. For example, if this value will be `continuumio/miniconda3` it would mean that basis of our container will already have ubuntu + python 3 + conda installed and we won't need to worry about python installation. Table below lists some useful values for `From:`. Unfortunately, the full list of all possible values does not exist.


| Value of `From:`           |  What is already inside |       Note           |
| :-------------------------:|:-----------------------:| :-------------------:|
| `ubuntu:14.04`             | 'naked' Ubuntu 14.04    | Unless you're 100% sure, it's better to use more up-to-date Ubuntu version |
| `ubuntu:18.04`             | 'naked' Ubuntu 18.04    | Same as above        |
| `ubuntu:20.04`             | 'naked' Ubuntu 20.04    | Used in 50% of times |
| `continuumio/anaconda2`    |    |                |
| `continuumio/miniconda2`   |    |                |
| `continuumio/anaconda3`    |    |                |
| `continuumio/miniconda3`   |    | Used in 49% of times|
| `rstudio/r-base:4.0-focal` | Ubuntu 20.04.4 + R v.4.0.5     | https://hub.docker.com/r/rstudio/r-base |
| `ibmjava`                  | Ubuntu 18.04.6 + Java v8.0.7.6 | |
| `julia:1.3`                | ||

Note: my search showed that windows is not containerized. 

### Sections (main content)
In the example above (link) you may have noticed starting with % after the header. % is the key symbol to start section. Each section has its definitive purpose and here we'll consider basic ones essential for the container creation. 

#### %post
This is the most important section. In essence, the absolute minimal recipe would consist of header and post section. If you're familiar with Ubuntu, you may know that you need to use `sudo` to install something system wide. Here, in container, you can avoid it, you're a root by definition. Here our metaphor from the introduction with an empty Ubuntu machine (especially if you use `ubuntu:20.04` header) comes into play. So here in this section you write all the same commands you would write if you would install a desired software on your Ubuntu machine. 

The lines below are my personal recommendations:

```
apt-get -qq -y update
# It is imperative to use -y with apt-get, so you don't have to interact with the container during it's creation
apt-get -qq -y install wget gcc libncurses5-dev zlib1g-dev libbz2-dev \
                               liblzma-dev make tabix
```


```
%post
    # Here we are located in the root of the system. Avaible folders are:
    export DEBIAN_FRONTEND=noninteractive
    TZ=Europe/Moscow
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
        
    apt-get update
    apt-get upgrade -y
    apt-get install -y wget curl \ # to download
                       unzip zip bzip2 tabix \ # to zip/unzip/compress files
git \ # speaks for itself!
gfortran perl \ # languages, fortran and perl. Python is already installed. R is separately
gcc g++ make cmake build-essential \ # compilers
software-properties-common \ # package manager
autoconf \ # automatically configure software source
ca-certificates \ # internet security

zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libncurses5-dev
libcurl4-openssl-dev libxml2-dev libz-dev
procps gnupg2 libffi-dev
libatlas-base-dev
libfontconfig1
libsm6
libtcl8.6
libtk8.6
libxrender1
libxt6

```
For the 100% reproducibility, you'd need to specify versions of the libraries.
```
apt-get install <package name>=<version>
```

This is the only (except header) essential section, everything else is embelishments and conviniences.  

If you need, you can of course download or create files and folders. 

#### %labels
Labels section provides a meta data for the container. Conventionally, one puts there a general information about the container, such as who have created it, organization, email to contact, etc. It's a free form section, you can put here whatever you'd like. The general format is a name-value pair. 
```
%labels
        CREATOR     Maria Litovchenko
        ORGANIZATION    UCL       
        EMAIL    m.litovchenko[at]ucl.ac.uk
        VERSION v0.0.1
```

#### %help
This section is a free text where usually an information which helps a user to interract with the container. It is displayed upon `singularity run-help` command. It is also nice to put here information about target and support software installed in this container.
```
%help
        Main software:
        All-FIT        v.1.0.0          https://github.com/KhiabanianLab/All-FIT

        Example run:
        singularity exec all-fit_v1.0.0.sif python /All-FIT.py --help
```

#### %environment
`%environment` section serves to define environmental variables in your container. In case you're not familiar with the environmental variables here is a little example. It is very nice that you can just open your terminal, navigate to any folder, and then type `samtools` and it will work, isn't it? But how does your system knows where to look for samtools executable? Though environmental variable of course! Usually, on _actual computer_ they are defined in bashrc file. This file is one of the first files your computer reads during booting and therefore each time you switch your computer on it knows where samtools is. So, the common format for the environmental variable to define a path to binary executable is: `export PATH=/where/to/install/bin:$PATH`. Obviously, environmental variables may not only define path to a certain software (or file), they can also define a variable, i.e. `PI=3.14`.
In container, they are defined in environment section. 

```
%environment
    export PATH=/where/to/install/bin:$PATH
    PI=3.14
```

Important note: in container all environmental variables are accessible only **after** container is created, but **not during its creation** (aka execution of %post section). So, if you need your samtools or PI during container creation as well, then you'll also have to define them in %post section. For example:

```
%post
    export PATH=/where/to/install/bin:$PATH
    PI=3.14
%environment
    export PATH=/where/to/install/bin:$PATH
    PI=3.14
```

#### %files
**This section can only be used if you build container on your computer. Can not be used during online build.** %files section is used to copy files from the host computer (where you build a container) inside the container. The general convention is that each line is a source and destination pair. Source has to be a valid path on your system and destination is a path inside container. However, this section significantly reduces reproducibilty of your container creation.
```
 %files
/usr/bin/Desctop/my_test_file /olala
```
#### %test
#### %runscript

This list of sections is not all inclusive. For the full list, please check with official documentation.
Now, after we get to know the insides of the singularity recipe, we can create a simliet one. Let's do it on the example of samtools.

### Conda & python packages
Due to the existence of `continuumio/miniconda3` header creating "pure python" containers is actually one of the easiest tasks. `continuumio/miniconda3` assures that both `python3`, `conda` and `pip` is already present in our container and we don't need to do anything to install them. Quite nice! In comparison to your usual installation of python packages, there is only one difference: `conda` and `pip` are not accesible in the root folder, because environmental variables were not set up. So in order to be able just type `conda` and `pip` as usual we need to set up environmental variables for them which in the recipe below is done with following lines: `export PATH=/opt/conda/bin/:$PATH` and `export PATH=/opt/conda/bin/:$PATH` (for pip).

ALWAYS USE  -y. This says 'yes' to any installation request without a need for interaction
 
Here is a simple example:
```
Bootstrap: docker
From: continuumio/miniconda3

%help
    Main software:
    numpy        v.1.0.0          https://github.com/KhiabanianLab/All-FIT
    
    Example run:
    cat 'import numpy' > test.py
    singularity exec numpy.sif python3 test.py

%labels
    CREATOR         Maria Litovchenko
    ORGANIZATION    UCL
    EMAIL           m.litovchenko[at]ucl.ac.uk
    VERSION         v0.0.1

%post
    # STEP 1: update your OS. ALWAYS DO IT!
    apt-get update && apt-get install
    
    # STEP 2: environmental variables for conda and pip
    export PATH=/opt/conda/bin/:$PATH
    
    # STEP 3: install python version you need (this is optional, but improves reproducibility)
    conda install python=3.8
    
    # STEP 4: install python packages with conda.
    conda install --channel conda-forge --channel bioconda -y \
                  numpy=1.21.5
%environment
    export PATH=/opt/conda/bin/:$PATH
```
Please note that for the enhanced reproducibility a certain version of numpy was requested. 
If during installation a package asks you to create an environment, don't do it. Usually in python environments are created to isolate different, sometimes incompatible packages from each other. If you do need to use two environments = two containers.

As you may notice, my personal recommendation line is not used in the container above. This is because we create a container 

Is it possible to install ubuntu software, like samtools or bwa in container with `continuumio/miniconda3`? Yes! Because `continuumio/miniconda3` is _Ubuntu_ + conda.

The example below is the recommended way to create a container with python packages installed. However, if for some reason you'd like to use `ubuntu:20.04`  header instead of `continuumio/miniconda3`, here is how you can install conda:
```
Bootstrap:docker
From:ubuntu:20.04

%help
    A test container to show installation of conda on Ubuntu 20.04

%post

apt update -y
        apt upgrade -y
        apt install -y wget bzip2

        # STEP 1: download miniconda v3.4 (check out https://repo.continuum.io/miniconda/ for other versions)
        cd /opt
        rm -fr miniconda
        wget https://repo.continuum.io/miniconda/Miniconda3-4.7.12-Linux-x86_64.sh -O miniconda.sh

        # STEP 2: install conda
        bash miniconda.sh -b -p /opt/miniconda
        export PATH="/opt/miniconda/bin:$PATH"
        
        # now conda is available and can be used, i.e.
        conda install --channel conda-forge --channel bioconda -y \
                  numpy=1.21.5
```

### R packages
For creaation of containers with R packages installed there is also a trick with header `rstudio/r-base:4.0-focal` which simplifies the build because essentially R is already installed. In you want another version of R, scroll to section above. In comparison to installation on your computer, where you would probably use R studio or just open plain R terminal and type `install.packages` you'd need to add `Rscript -e` as in the example below. As many of us use biocondactor pakcages, I also added example for their installation.

```
Bootstrap: docker
From: rstudio/r-base:4.0-focal

%help
    A test container showing how to install R packages

%post 
Rscript -e "install.packages(c('data.table'), quietly = TRUE)"
        Rscript -e "install.packages(c('BiocManager','optparse', 'readr', \
                                       'pheatmap', 'RColorBrewer'),
                                     quietly = TRUE)"
        Rscript -e "BiocManager::install(c('DESeq2', 'edgeR', 'tximport'), \
                                         ask=FALSE, update=FALSE)"
```

In case you need to install R on ubuntu, here is how it's done:

```
Bootstrap: docker
From: ubuntu:18.04

%help
        Main software:
        R v4.0.0

%labels
      CREATOR           Carlos Martinez Ruiz
            ORGANIZATION        UCL

%post
        export DEBIAN_FRONTEND=noninteractive
        apt-get -qq -y update
        apt-get -qq -y install wget gcc libncurses5-dev zlib1g-dev libbz2-dev gnupg2 \
                               software-properties-common libcurl4-openssl-dev libssl-dev libxml2-dev
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
        add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'
        apt-get -qq -y dist-upgrade
        apt-get -qq -y install r-base r-base-core r-recommended

        # R is installed!

```

### Java

### Julia
### Compound containers: Ubuntu package + R packages + python packages
If you'd like to create a frankenstein singularity container which will contain some bash libraries, R libraries and python libraries, use `continuumio/miniconda3` header.

Cheat code: conda can have a lot of ubuntu packages!

#### External files to download into package: dropbox, google drive 
#### How to use container from docker as a base and why not to do it.

#### Sandbox container creation
why I don't reccomend building based on other people's docker containers: they change! Especially something latest.

#### Can I modify already created container? YES! Should I? NO!
#### Examples

## Using containers
_This section implies that you have singularity installed on your computer / server. For MAC OS installation guide, check our this link, and for Ubuntu - this one. If you have a Windows machine, you're on your own._

```
singularity pull 
```

Once your container is created, you can interact with it in several modes. 
1. **Checking integrity.** As described above a container is something like remote server in the shell of a sif file. If it's like server, we can log in _inside_ it and check installation of the software. To get inside the container, use _shell_ command to tell _singularity_ to let you in:
```
singularity shell your_container.sif
```
This will lead to a change in your terminal to:
```

```
Congratulations! We're inside the container! Command:
```
ls -l
```
will display all the files and folders inside the container:
```
```
You can even see the file test_file_inside_the_container which we created above!
Now, you can check on software installation and in general behave in the same way as you would just in usual terminal.
2. **Executing software from container.** Singularity makes it very easy to run the software from the container. Essentially, all the commands used in terminal to run the software will stay the same. The only change one needs to make is to put `singularity exec your_container.sif` in front of the command. For example, to execute `samtools` which is installed in our test container, the following command is used:
```
singularity exec samtools_in_a_box.sif samtools --help
```
Following message should appear on your screen proving that `samtools` worked:
```
```
Basically, you can put any bash command after `singularity exec your_container.sif` and it will be executed inside the container. For example, to list files inside the container:
```
singularity exec samtools_in_a_box.sif ls -l
```
2a. **Executing software from container if it is not globally accesible** In the example above samtools is globaly accessible meaning that regardless of the folder _inside_ the container, if a `samtools` command is called, `samtools` will be executed. However, it can happen that a software you (or someone else) put inside the container was not made globally accesible. In such case, a full path to software _inside_ the container should be given after `samtools_in_a_box.sif `. During creation of `samtools_in_a_box.sif` a `say_cheese.sh` script was created in folder _tiny_scripts_. In order to execute it:
```
singularity exec samtools_in_a_box.sif /tiny_scripts/say_cheese.sh
```
Result
```
```
The **slash** in front of the `tiny_scripts/say_cheese.sh` is **imperative** as it indicates the root.

2b. **Bining**. All commands above did not require files from your computer to serve as an input, which of course will not be the case then you'll use the container for data analysis. There is a small detail in the usage of singularity containers associated with location of your input files. Let's create a small sam file to serve as test one:
```
echo > small_test.sam
echo >> small_test.sam
```
Now, let's use our container with samtools to convert that sam to bam format:
```
singularity exec samtools_in_a_box.sif samtools view -bS small_test.sam > small_test.bam
```
If you check now your computer with `ls -l`, you'll see that small_test.bam was created. Container worked! Hooray! However, it is unlikely that all of your imput files will be located in the same directory as a container. So let's move our small_test.sam to the directory just outside directory which contains our container:
```
# create the directory
mkdir ../sam_files_dir/
# move
mv small_test.sam ../sam_files_dir/
```
and let's try to execute the same command again:
```
singularity exec samtools_in_a_box.sif samtools view -bS ../small_test.sam > small_test_1.bam
```
Error occured:
```
```

The error message informs that file small_test.sam does not exist! Of course, in reality it does, just the container doesn't "see" it meaning that it can't detect it. This problem is solved with _binding_. Singularity allows you to map directories on your host system to directories within your container using _bind_ mounts. Binding is very similar with mounting directories of the remove server to your own computer. Binding is performed via `--bind` option given to singularity followed by a full path to the **folder** on your computer you'd linke to bind and full path to the folder in the container you'd like the original folder be bound to separated by ":". For example: `singularity --bind path_on_your_computer:path_to_be_used_inside_the_container`. The folder inside the container you'd like your folder on the computer to be bound to does not have to exist. In fact, I find it **the most convinient to use exactly the same full path to the folder on computer as the binding path inside the container**. This will ensure that all your code which uses absolute paths to the input files will runs smoothly. For example, the container with samtools we've created above is located in _containers_ folder, and small_test.sam is located in _sam_files_dir_. Both _containers_ folder and _sam_files_dir_ are subfolders of _singularity_showcase_ folder. Let's use it for binding. I  genral, it's a good idea to use as bind path a directory which is parent to both directory containing your container (sif file) and your input files.
``` 
singularity —bind /singularity_showcase/:/singularity_showcase/ exec samtools_in_a_box.sif samtools view -bS /singularity_showcase/sam_files_dir/small_test.sam > small_test_1.bam
```
Worked!

## Tips, tricks 
How to see recipe of already build container?
singularity run-help my_container.sif

## Sources:
https://sylabs.io/guides/3.5/user-guide/definition_files.html
