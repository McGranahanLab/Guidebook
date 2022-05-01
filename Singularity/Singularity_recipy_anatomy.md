# Anatomy of Singularity's recipy
## What is a recipy aka definition file?
It is written in bash.
## Main sections
Example of the definition file (singularity recipy):
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


#### Table with headers (from) and what's already installed in them
#### Conda & python packages
#### R packages
#### Java
#### Julia
#### External files to download intp package
#### How to see recipe of already build container?
#### Examples

why I don't reccomend building based on other people's docker containers: they change! Especially something latest.
Separate topics:
#### Binding

### Sources:
https://sylabs.io/guides/3.5/user-guide/definition_files.html
