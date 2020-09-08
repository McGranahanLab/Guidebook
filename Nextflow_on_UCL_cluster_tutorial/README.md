# Nextflow execution on UCL cluster

This tutorial is dedicated to provide a working example of how to run nextflow 
pipelines on UCL cluster (and submit jobs from nextflow). This tutorial assumes
that you are familiar with basis of Nextflow, Singularity and job submitting in
Sun Grid Environment (SGE). If not, please find below resources to familiarize 
yourself:

⋅⋅* [Nextflow documentation](https://www.nextflow.io/docs/latest/), [Nextflow examples](https://www.nextflow.io/example1.html)

⋅⋅* [Singularity tutorial](https://singularity-tutorial.github.io/)

⋅⋅* [UCL HPC guide](https://hpc.cs.ucl.ac.uk/full-guide/), [SGE job submission](http://www.softpanorama.org/HPC/Grid_engine/sge_submit_scripts.shtml)

### Step 1: configure your account to run nextflow
Like with any other software, you need to load module with nextflow from the 
library. Yet, nextlow requires java be available at hand on server, so it's 
needed to be loaded too. I suggest to add following lines to `~/.bashrc` so 
modules would load and be available as soon as you login to the cluster:

```shell
export PATH=/share/apps/jdk-10.0.1/bin/:${PATH}
export JAVA_HOME=/share/apps/jdk-10.0.1/
export PATH=/share/apps/colcc/nextflow/:${PATH}
```
If you don't want to add these lines into your `~/.bashrc`, just simply run 
them in terminal. However, once you logout and login again, nextflow won't be
available anymore.

To test that nextflow is loaded, type in terminal:
```shell
nextflow -v
```
Output should be:
```shell
nextflow version 20.07.1.5412
```

### Step 2: Examine main.nf
```main.nf``` is just a regular nextflow script, there is nothing which would 
distinguish it from scripts run on local machines. In fact, it could be run on
local computer.

The script contains 4 processes: 
1. download_reference_genome - downloads chr6 of hg19 from ensembl
2. index_reference_genome_samtools - indexes downloaded fasta with samtools
3. index_reference_genome_bwa - indexes downloaded fasta with bwa
4. index_reference_genome_picard - indexes downloaded fasta with picard

All indexing processes will be executed in parallel, i.e. indexing with 
samtools and bwa will be computed at the same time. This is done in order to 
speed up the process of indexing. 

Note that despite indexing will be done with samtools, bwa and picard, we do 
not load corresponding modules. This is because we will use singularity 
container (see below).

Upon successful completion of the workflow a message will be shown and work
directory containing temporary files could be removed (```work/```). Also, directory
```_assets/reference_genome/``` will be created containing following files:

```
test.Homo_sapiens.GRCh37.chr6.dna_sm.dict
test.Homo_sapiens.GRCh37.chr6.dna_sm.fa
test.Homo_sapiens.GRCh37.chr6.dna_sm.fa.amb
test.Homo_sapiens.GRCh37.chr6.dna_sm.fa.ann
test.Homo_sapiens.GRCh37.chr6.dna_sm.fa.bwt
test.Homo_sapiens.GRCh37.chr6.dna_sm.fa.fai
test.Homo_sapiens.GRCh37.chr6.dna_sm.fa.pac
test.Homo_sapiens.GRCh37.chr6.dna_sm.fa.sa
```

### Step 3: Configuration files

In comparison to standard nextflow run, we need to make 2 changes: 1) tell 
nextflow that we run it on SGE 2) tell to use singularity containers

#### Configuration to nextflow on SGEs

All code described below is in ```conf/ucl.conf```, please examine the file 
carefully. 

In general, to let nextflow know that we will run it on server with SGE 
following directives under scope executor are added:

```nextflow
executor {
    name = 'sge'
    queueSize = 75
    pollInterval = '30sec'
}
```
⋅⋅* ```name``` states that SGE is run on server
⋅⋅* ```queueSize``` limits amount of jobs which nextflow will submit. Default is 100.
⋅⋅* ```pollInterval``` tells how often a poll occurs to check for a process termination.

Then the workflow will be executed every process will be submitted to the 
cluster as a separate job. This is why we need to specify ```clusterOptions``` 
under process directives.

```nextflow
process {
    executor = 'sge'
    errorStrategy = 'finish'
    cache = 'lenient'

    clusterOptions = '-S /bin/bash -cwd -l h_rt=24:00:00,h_vmem=1G,tmem=2G'

    withLabel: 'XL' {
        cpus = 8
        penv = 'smp'
        clusterOptions = '-S /bin/bash -cwd -l h_rt=24:00:00,h_vmem=32G,tmem=32G -pe smp 8'
   }
}
```

⋅⋅* ```executor = 'sge'``` defines that every process will be run under SGE 
    executor defined above
⋅⋅* ``` clusterOptions = '-S /bin/bash -cwd -l h_rt=24:00:00,h_vmem=1G,tmem=2G' ```
    cluster options for processes without any label. Cluster options are 
    basically a linearized header of the classical job submission script. 
    ⋅⋅⋅⋅* Part ```-S /bin/bash``` is necessary and is followed by various options which 
    are usually found in the header of job submitting script. 
    ⋅⋅⋅⋅* In the example above ```-cwd``` tell that process will use the 
    directory, where the job has been submitted, as the working directory. 
    ⋅⋅⋅⋅* ```-l h_rt=24:00:00,h_vmem=2G,tmem=2G``` determines wall time (24h), 
    virtual and physical memory limits. Full list of all directives is available 
    [here](https://hpc.cs.ucl.ac.uk/full-guide/)
    ⋅⋅⋅⋅* please note that here we didn't specify amount of cores a process 
    will be run on, so it will be 1 as by default.
⋅⋅* ```clusterOptions = '-S /bin/bash -cwd -l h_rt=24:00:00,h_vmem=32G,tmem=32G -pe smp 8'```
    This line defines resources available to a process requiring extra large 
    amounts of memory and time. Please note, that here ```-pe smp 8``` is added which
    gives to a process 8 cores to run on. Since the process will be computed on several cores,
    we also need to specify ```penv = 'smp'``` directive. Directive ```cpus = 8``` here __does not__
    set up number of cpus available to the process. I put it there so I could refer to the number of
    requested cores in the process command via ```task.cpu``` and set up correct number of threads.
    Please see index_reference_genome_picard process in main.nf for an example.

#### Configuration to use Singularity with Nextflow

Code described below is in ```nextflow.config```, please examine the file 
carefully. 

In order to allow nextflow use singularity containers a following scope needs 
to be added:

```nextflow
singularity {
    enabled = true
    autoMounts = true
    runOptions = "--bind ${PWD}"
}
```
Out of the options above, the most important is ```runOptions = "--bind ${PWD}"```.
It allows a singularity container to access the files outside the container by mounting
paths inside the container. This is because unlike Docker, Nextflow does not mount 
automatically host paths in the container when using Singularity. It expects they are 
configure and mounted system wide by the Singularity runtime. 

The code described below is in ```conf/ucl.conf```.

Usually, nextflow is capable of automatically pulling  containers from multiple
sources, inclusing docker and singularity library (https://cloud.sylabs.io/library)
and no pre-run download of containers is needed. However, UCL server has a 
firewall which prevents automatic pulling and therefore containers have to be 
downloaded before the pipeline run. Be careful if you would like to use Docker 
container as they don't always work under Singularity. It is better to create a 
corresponding Singularity container, ask Maria for help if needed.

For this tutorial we will need just one container which we're going to pull 
from singularity library. This container contains bwa, samtools and picard.

```shell
mkdir _singularity_images
cd _singularity_images
singularity pull library://marialitovchenko/default/bwa:v0.7.17 
```
Now we can let our processes know that we have downloaded the container and 
they can use it:

```nextflow
   params {
        singularityDir="${PWD}/_singularity_images/"
   }

   /* Containers */
   withName:index_reference_genome_samtools {
        container = "${params.singularityDir}bwa_v0.7.17.sif"
   }

   withName:index_reference_genome_picard {
        container = "${params.singularityDir}bwa_v0.7.17.sif"
   }
        
   withName:index_reference_genome_bwa {
        container = "${params.singularityDir}bwa_v0.7.17.sif"
   }
```

### Step 4: running Nextflow on SGE with possibility to submit jobs
Usually to submit a job one would create a script with scheduler directives in
the header under hashtags (see [example here](https://hpc.cs.ucl.ac.uk/full-guide/))
followed by call to software one wants to use. It __will not__ work this way with
nextflow. Upon run of a classical job script the job script is compiled on your
__login__ node, and then it sends jobs from login node to __compute__ nodes. Nextflow
__has to be run__ on __login__ node to be able to submit jobs to __compute__ nodes. In other
words, __do not put a call to nextflow in your job submission script__.

To run nextflow type in terminal:
```shell
nextflow run main.nf -profile ucl -entry prepare_reference_genome -bg 1>nf.out 2>nf.err 
```

⋅⋅* ```-profile ucl``` tells nextflow to run it with UCL SGE profile configures in ```conf/ucl.conf```
⋅⋅* ```-entry prepare_reference_genome``` specifies workflow to execute
⋅⋅* ```-bg``` _puts nextflow run in background_ this options allows you to run long jobs
without constantly keeping terminal open.
⋅⋅* ```1>nf.out 2>nf.err``` redirects messages and errors into nf.out and nf.err respectively.

After you press enter after the command, nothing should happen, no message should appear. However,
if you do 
```shell
qstat
```
you should see something like
```
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
2377141 0.00000 nf-prepare username     qw    09/08/2020 13:09:34                                2        
```
which means first process, namely downloading the genome, is now in the queue and it will use 2 processes. It may take time to appear.

Yay! Nextflow is running!

Now it's a good time to log off by typing
```shell
exit
```
in a terminal and log back in again. You have to type ```exit``` and not just close the terminal, because
otherwise you background process (nextflow included) will be terminated.

When you log in back again, download job could already be running:

```
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
2377141 0.00000 nf-prepare username     r    09/08/2020 13:09:34 all.q@french-602-25.local      2        
```

After some time, three indexing jobs will be running in parallel:

```
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
2377145 0.00000 nf-prepare username     r    09/08/2020 13:12:34 all.q@saunders-608-1.local      4        
2377146 0.00000 nf-prepare username     r    09/08/2020 13:12:34 all.q@saunders-608-7.local      8        
2377147 0.00000 nf-prepare username     r    09/08/2020 13:12:34 all.q@french-602-25.local       6 
```
Note: sometimes, while workflow is still running, you may see output of qstat empty. It's ok,
it means scheduler haven't yet started next processes of the pipeline.

If you would like to check on the status of the pipeline other than on ```qstat```,
you can display content of nf.out and nf.err:

```
tail nf.* 
```

Upon successful workflow completion following message will be written in ```nf.out```:
```
N E X T F L O W  ~  version 20.07.1
Launching `main.nf` [modest_tuckerman] - revision: 31df34739a
WARN: DSL 2 IS AN EXPERIMENTAL FEATURE UNDER DEVELOPMENT -- SYNTAX MAY CHANGE IN FUTURE RELEASE
[c4/4303ae] Submitted process > prepare_reference_genome:download_reference_genome (download_reference)
[f8/c0b748] Submitted process > prepare_reference_genome:index_reference_genome_bwa (index_reference_bwa)
[a1/70f0a9] Submitted process > prepare_reference_genome:index_reference_genome_samtools (index_reference_samtools)
[59/6655b5] Submitted process > prepare_reference_genome:index_reference_genome_picard (index_reference)
Pipeline completed at: 2020-09-08T16:04:49.321214+01:00
Execution status: OK
```
Success! Now you can remove work directory containing temporary files.
