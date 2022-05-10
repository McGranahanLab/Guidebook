# Anatomy of Singularity's recipy
## What is a recipy aka definition file?
It is written in bash.
## Recipy skeleton
Example of the simpliest definition file (singularity recipy):
```
Bootstrap: docker
From: ubuntu:20.04

%post
    apt-get -y update && apt-get install -y python

%runscript
    python -c 'print("Hello World! Hello from our custom Singularity image!")'

```

In general, Singularity definition file can be divided into 2 main parts: **header** and **sections**. 

### Header Section
* **Header** part is usually composed out of 2 lines with which recipe starts. In the example above it is `Bootstrap: docker` and `From: ubuntu:20.04`. `Bootstrap` and `From` here are key words, like name of parameters, and `docker` and `ubuntu:20.04` are the values for those parameters. The recipe should always start from the `Bootstrap:` key word. Header of the recipe determines the operation system for the future container, which in turn controls what will already be pre-installed in the container without need for our intervention. In 99.9% of the cases line `Bootstrap: docker` will be the first line of your recipy. It says that the base OS (determined by `From:` line) will be pulled (downloaded) from Docker Hub. You can also put `Bootstrap: library`, and then the base OS will be pulled from Singularity Hub. In the majority of the cases, they are interchangeable. There are more various values you can give to `Bootstrap:`, you can read about them [](here). The `From: ` line is quite powerful. Ordinary `From: ubuntu:20.04` tells Singularity engine that you'd like to use "naked" Ubuntu v20.04 as a basis of your container, meaning that there will be nothing else installed. However, we can change value `ubuntu:20.04` to something else to allow some weight being lifted for us. For example, if this value will be `continuumio/miniconda3` it would mean that basis of our container will already have ubuntu + python 3 + conda installed and we won't need to worry about python installation. Table below lists some useful values for `From:`. Unfortunately, the full list of all possible values does not exist.


| Value of `From:`|  What is already inside |       Note           |
| :-------------: |:-----------------------:| :-------------------:|
| `ubuntu:14.04`  | 'naked' Ubuntu 14.04    | Unless you're 100% sure, it's better to use more up-to-date Ubuntu version |
| `ubuntu:18.04`  | 'naked' Ubuntu 18.04    | Same as above        |
| `ubuntu:20.04`  | 'naked' Ubuntu 20.04    | Used in 50% of times |
| `continuumio/anaconda2`  |    |                |
| `continuumio/miniconda2`  |    |                |
| `continuumio/anaconda3`  |    |                |
| `continuumio/miniconda3`  |    | Used in 49% of times|
rstudio/r-base:4.0-focal
https://hub.docker.com/r/rstudio/r-base
ibmjava
https://hub.docker.com/_/openjdk

Note: my search showed that windows is not conteinarized. 

### Sections (main content)
In the example above (link) you may have noticed starting with % after the header. % is the key symbol to start section. Each section has its definitive purpose and here we'll consider basic ones essential for the container creation. 

#### %post
This is the most important section. In essence, the absolute minimal recipe would consist of header and post section. If you're familiar with Ubuntu, you may know that you need to use sudo to install something system wide. Here, in container, you can avoid it, you're a root by defition. Here our metaphor from the introduction with an empty Ubunntu machine (especially if you use `ubuntu:20.04` header) comes into play. So here in this section you write all the same commands you would write if you would install a desired software on your Ubuntu machine. 

The lines below are my personal reccomendations:

```
apt-get -qq -y update
# It is imperative to use -y with apt-get, so you don't have to interact with the container during it's creation
apt-get -qq -y install wget gcc libncurses5-dev zlib1g-dev libbz2-dev \
                               liblzma-dev make tabix
```


```
%post
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

#### Conda & python packages
Note: where conda is located
#### R packages
#### Java
#### Julia
#### External files to download into package: dropbox, google drive 
#### How to see recipe of already build container?
#### How to use container from docker as a base and why not to do it.
#### Sandbox container creation
why I don't reccomend building based on other people's docker containers: they change! Especially something latest.
#### Can I modify already created container? NO!
#### Examples

### Usage
singularity run-help my_container.sif
Separate topics:
#### Binding
All files are usually located in '/'

### Sources:
https://sylabs.io/guides/3.5/user-guide/definition_files.html
