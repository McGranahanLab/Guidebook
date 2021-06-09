This tutorial assumes that you can login into UCL cluster.

## The job launching script
To run your calculations on UCL cluster you will need to create a launching 
script which will tell the cluster how much memory, how many cores and for how
long you'd like a script to be run for as well as which software you'd like to
run. Let's have a look at simpliest example of launching script:

```
#!/bin/bash

#$ -l tmem=1G
#$ -l h_vmem=1G
#$ -l h_rt=01:00:00
#$ -S /bin/bash
#$ -N test
#$ -cwd

# Loading (pointing out the path) to samtools
export PATH=/share/apps/genomics/samtools-1.9/bin/:${PATH};

echo "Hello!"

samtools --help

```

Script consists out of header lines starting with `#$` and body. Header lines
specify memory, running time, etc:

* `#$ -l tmem=1G` and `#$ -l h_vmem=1G` specifies RAM which you would like to use, 1Gb in this case. Must be present at all times.
* `-l h_rt=01:00:00` specifies time you'd like your job to be run for, 1h in this case. Since UCL cluster has no queuing systemm this parameter is extra important. Must be present at all times.
* `-S /bin/bash` tells that this script is a bash script. Must be present at all times.
* `-N test` gives our job a name. All the messages and errors the job will produce will be stored in file names job_name.o<some numbers>
* `-cwd` Use current directory as start working directory for the job launcher.

To submit job:
```
qsub < little_job_script.sh
```

To check job status:
```
qstat
```

Then you should see this while job is waiting for its execution:
```
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
3372728 0.00000 test       mlitovch     qw    06/02/2021 11:24:29                                    1        
```
... and then it's running:
```
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
3372728 0.52324 test       mlitovch     r     06/02/2021 11:24:34 all.q@saunders-608-1.local         1        
```
Column state tells you the status of your job in the sustem: `qw` - pending, `r` - running. Full list of the
codes and their meaning is below:


| **Category**  | **State**                                      | **SGE Letter Code** |
| ------------- |:-----------------------------------------------| :------------------ |
| Pending       | pending                                        | qw                  | 
| Pending       | pending, user hold                             | qw                  |
| Pending       | pending, system hold                           | hqw                 |
| Pending       | pending, user and system hold                  | hqw                 |
| Pending       | pending, user hold, re-queue                   | hRwq                |
| Pending       | pending, system hold, re-queue                 | hRwq                |
| Pending       | pending, user and system hold, re-queue        | hRwq                | 
| Pending       | pending, user hold                             | qw                  |
| Pending       | pending, user hold                             | qw                  |
| Running       | running                                        | r                   |
| Running       | transferring                                   | t                   |
| Running       | running, re-submit                             | Rr                  |        
| Running       | transferring, re-submit                        | Rt                  |
| Suspended     | obsuspended                                    | s,  ts              |
| Suspended     | queue suspended                                | S, tS               | 
| Suspended     | queue suspended by alarm                       | T, tT               |
| Suspended     | allsuspended withre-submit                     | Rs,Rts,RS, RtS, RT, RtT |
| Error         | allpending states with error                   | Eqw, Ehqw, EhRqw        |
| Deleted       | all running and suspended states with deletion | dr,dt,dRr,dRt,ds, dS, dT,dRs, dRS, dRT | 

After the job is completed, two files will be created: test.e<some numbers> and 
test.o<some numbers>. The first one contains error messages and should be empty
and the second one contains just messages and should have our "Hello" + samtools
help output.

## Multicore programs & RAM for them
**IMPORTANT NOTE:** before you just request more cores for your job and launch
it hoping that more cores will speed up the execution, *check that your code can be
parallelized!*. For example, if you want to run `samtools flagstat` command, it
has no option to specify number of threads/cores to use, therefore, it can only
be run in single thread/core mode. This means that you can give it as many cores
as you'd like, it will still be using just 1.

In order to run your script in multicore mode, you need to add `#$ -pe smp 8` to the header of your launching script.
The number after `smp` specifies number of core you'd like to use. For example:

```
#!/bin/bash

#$ -l tmem=1G
#$ -l h_vmem=1G
#$ -l h_rt=01:00:00
#$ -S /bin/bash
#$ -N test_multicore
#$ -cwd
#$ -pe smp 8
```

However, one should note that `tmem` and `h_vmem` specify amount of RAM _per core_, i.e. in the example above a total amount of requested RAM is 1G * 8cores = 8G. And in the example below:

```
#!/bin/bash

#$ -l tmem=1G
#$ -l h_vmem=1G
#$ -l h_rt=01:00:00
#$ -S /bin/bash
#$ -j y
#$ -N test_multicore
#$ -cwd
```
there `-pe smp` option is not specified, and therefore considered just 1 core in use, amount of requested RAM is 1G * 1core = 1G

## Getting files to and from UCL cluster

* If you use Windows - you're on your own =)
* If you have mounted UCL cluster as described in the newcomers guide - just drag and drop in the corresponding window.
* To copy from terminal:
```
# to copy a single file from UCL cluster:
scp <your_user_name>@gamble:/SAN/colcc/<path_to_your_file> . 
# it will only work if your set up ssh jump as described in the newcomers guide
# dot means copy in this folder

# to copy a folder from UCL cluster:
scp -r <your_user_name>@gamble:/SAN/colcc/<path_to_your_folder> . 

# to copy a file to UCL cluster:
scp <your file> <your_user_name>@gamble:/SAN/colcc/<path_to_your_folder>

# to copy a folder to UCL cluster:
scp -r <your folder> <your_user_name>@gamble:/SAN/colcc/<path_to_your_folder>
```

## How to run java applications, i.e. GATK, Picard, etc
There are couple of tricks to run java on UCL cluster. In general, java applications are coming in a shape of jar files. For example, picard jar: `/share/apps/genomics/picard-2.20.3/bin/picard.jar`. The command to launch jar file is:
```
java -jar path_to_your_jar
```

More specific example:
```
# this export makes downstream code a bit more compact
export PICARD_PATH=/share/apps/genomics/picard-2.20.3/bin/picard.jar
java -jar $PICARD_PATH
```

... and here come the tricks!

_Trick #1_: Running multithreaded Java
```
java -jar -XX:ParallelGCThreads=8 $PICARD_PATH 
```
Insert your number of threads in place of 8. Don't forget to put `#$ -pe smp 8` in the header of your job script.

_Trick #2_: Managing Java memory
Unfortunately, Java is very greedy. Unless a precise amount of memory application should use is specified in the `java -jar` command, it will use _all_ available memory which will cause application to crush with following error:
```
Error occurred during initialization of VM
Could not reserve enough space for ... object heap
```

Therefore, we need to specify certain flags which would tell java how much memory it's allowed to use.  The flag Xmx specifies the maximum memory allocation pool for a Java Virtual Machine (JVM), while Xms specifies the initial memory allocation pool. This means that your JVM will be started with Xms amount of memory and will be able to use a maximum of Xmx amount of memory. For example, starting a JVM like below will start it with 1Gb of memory and will allow the process to use up to 2Gb of memory:
```
export PICARD_PATH=/share/apps/genomics/picard-2.20.3/bin/picard.jar
java -jar -Xms1G -Xmx2G $PICARD_PATH
```
However, the memory which you should request in the header of your job script, should be a bit (start with 20%+) more than the one you give to java application. Long story short, this is because Java had a bad garbage collection. In the example below, I set tmem and h_vmem to 3Gb for that reason.

```
#!/bin/bash

#$ -l tmem=3G
#$ -l h_vmem=3G
#$ -l h_rt=01:00:00
#$ -S /bin/bash
#$ -j y
#$ -N java_test
#$ -cwd

export PICARD_PATH=/share/apps/genomics/picard-2.20.3/bin/picard.jar
java -jar -Xms1G -Xmx2G $PICARD_PATH
```

_Note #1_: Java in interaction session
Apparently, during the interaction session, Java can occupy only a very small amount of memory from the amount you requested. For example, in session with requested 4G of memory:
```
qrsh -l h_vmem=4G,tmem=4G,h_rt=1:0:0
```
it can use only 100Mb:

```
export PICARD_PATH=/share/apps/genomics/picard-2.20.3/bin/picard.jar
# works
java -jar -Xms100M -Xmx100M $PICARD_PATH
# gives an error
java -jar -Xms218M -Xmx218M $PICARD_PATH
```

## Jobs with lots of temporary files (scratch)
## Jobs with shared static resourses (i.e. reference genome)
## Lots of very short jobs
