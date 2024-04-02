---
output:
  pdf_document: default
  html_document: default
---
# Newcomers guide

Welcome to Nicholas McGranahan lab! We compliled a short guide for you to help you with the overwhelming amount of information you might face upon your arrival. We are a bioinformatics lab and therefore are working on several computational servers: UCL, CAMP (Crick institute) and GEL (Genomics England). TRACERx data for now are located at CAMP, but we are working on moving them to UCL.

Below you can find a quick guide to how to get access to the various clusters / social platforms / etc.

UCL email address
------------

Computational clusters
------------

## How to: get access to UCL cluster  ##

### An algorith to apply for access to UCL HPC: ###
1. Get your computer science (CS) account here: https://tsg.cs.ucl.ac.uk/apply-for-an-account/. Put Nicholas McGranahan as “Dept. of Computer Science Sponsor”. It will take a couple of days to get an answer. Also, you should have a cell phone so they could text you the password.
2. After you have your computer science account, apply for a computer science cluster account: https://hpc.cs.ucl.ac.uk/account-form/. Do not fill in “Machine IP” or “Software requirements” fields
3. In meantime, you can read carefully a user guide to the HPC here: https://hpc.cs.ucl.ac.uk/ (username: hpc, password: comic)
4. Once you have your cluster account, you can apply for storage space for your project, if known and needed, here: https://hpc.cs.ucl.ac.uk/storage-form/

Before accessing to the server, please read this: https://hpc.cs.ucl.ac.uk/quickstart/ and this https://hpc.cs.ucl.ac.uk/full-guide/. We usually use `gamble` for our computations.

To test your connection to the server, type in your terminal:

```
ssh <your user name>@tails.cs.ucl.ac.uk # use your CS account password
ssh <your user name>@gamble.cs.ucl.ac.uk # use your CS account password
```

Congrats! You’re on the cluster.

### Establishing shorcuts to access the cluster (aka ssh jump) ###
Code block above shows you a usual way to access cluster: though two ssh's. However, then you work a lot on cluster it might not be so convinient: it requires a lot of typing, passwords, and in addition you can't mount gamble to your computer to make acceess to files easy. Ssh jump can take care of this, and you'll be able to log in directly to gamble by just typing `ssh gamble`. You only need to complete the procedure below once.

**Step 1** : add keys to tails to your computer

1. Open your terminal
2. Type `cd .ssh`. If you get an error that folder doesn't exist, do `mkdir .ssh` and then `cd .ssh`
3. Type `ssh-keygen`. Enter tails as name and leave the password blank.
4. Type `nano config`. The config file will be openned, insert in it:

```
Host tails 
  User <your_user_name>
  IdentityFile ~/.ssh/tails
  HostName tails.cs.ucl.ac.uk
  ForwardAgent yes
Host gamble
  User <your_user_name>
  IdentityFile ~/.ssh/gamble
  HostName gamble.cs.ucl.ac.uk
  ProxyJump tails:22
```

Don't forget to replace <your_user_name> with your actual user name. Save the file and exit according to the commands displayed at the bottom of the screen

5. Type `ssh-copy-id -i tails.pub tails`. This will copy the key you've just created to tails
6.  Now you can just `ssh tails` without password to get to tails cluster.

**Step 2** : add keys to gamble on tails

1. Open your terminal
2. Type `ssh tails`. Now you're on tails (UCL cluster).
3. Type `cd .ssh`. If you get an error that folder doesn't exist, do `mkdir .ssh` and then `cd .ssh`
4. Type `ssh-keygen`. Enter gamble as name and leave the password blank.
5. Type `nano config`. The config file will be openned, insert in it:

```
Host gamble 
User <your_user_name>
IdentityFile ~/.ssh/gamble
HostName gamble.cs.ucl.ac.uk

```
Don't forget to replace <your_user_name> with your actual user name. Save the file and exit according to the commands displayed at the bottom of the screen

6. Type `ssh-copy-id -i gamble.pub gamble` . This will copy the key you've just created to gamble
7. Type `exit` to exit tails and return back to your computer.

**Step 3**: add keys from gamble to your computer

1. Open your terminal
2. Type `ssh-keygen`. Enter gamble as name and leave the password blank.
3. Type `ssh-copy-id -i gamble.pub gamble`. This will copy the key you've just created to gamble

That’s it! Now you can just do `ssh gamble` and get on gamble!

:warning: If you're planning to use nextflow on the UCL cluster, you will need to login on a special node - `askey`.  It is accessible though gamble, i.e. you first need to `ssh gamble`, and then `ssh <your_user_name>@askey.cs.ucl.ac.uk` :warning:

### Mounting cluster on your computer (only if ssh jump is established) ###

Mounting will allow you to open folders from gamble cluster as usual on your computer and copy to/from cluster files just by dragging and dropping them.

1. Install sshfs: https://command-not-found.com/sshfs
2. Type in the terminal to create folder where home folder from gamble will be mounted `mkdir -p ~/gamble-home`
3. Perform mounting of gamble home folder: 

```
sshfs gamble: ~/gamble-home -oauto_cache,follow_symlinks -ovolname=GambleHome,defer_permissions,noappledouble,local
```

4. Type in the terminal to create folder where mcgranahanlab folder from gamble will be mounted `mkdir -p ~/gamble-mcgranahanlab`

5. Perform mounting of mcgranahanlab folder: 

```
sshfs gamble:/SAN/mcgranahanlab/ ~/gamble-mcgranahanlab -oauto_cache,follow_symlinks -ovolname=Gamble-McGranahanlab,defer_permissions,noappledouble,local
```
6. To unmount, type `umount ~/gamble-mcgranahanlab ~/gamble-home`

This is manual for mounting on Mac, for other systems, check out: https://support.nesi.org.nz/hc/en-gb/articles/360000621135-Can-I-use-SSHFS-to-mount-the-cluster-filesystem-on-my-local-machine-


### Main folders on the cluster ###
Our main folder is accessible via : `cd /SAN/mcgranahanlab/general/`. Once you’re in, please create a folder for yourself: `mkdir your_name`. Please be aware that we should only store scripts in that folder, and no data. To store data, request storage space for your project, see point 4 above.

**Please apply for the storage space for your project to store your data / results**

### Avaible software ###
You can list all the available software here:  `ll /share/apps/`, and genomics-specific like this: `ll /share/apps/genomics/`


Ed Martin (`e.martin@cs.ucl.ac.uk`) is our contact for the cluster questions, he’s very responsive. But please don’t abuse this link: first ask people in the lab.

## Crick cluster access (CAMP) ##

1. Install GlobalProtect VPN (instructions on [crick intranet](https://intranet.crick.ac.uk/our-crick/it-support/pages/vpn-virtual-private-network#how-to-install-the-globalprotect-software))
2. Get in touch with HPC to set up an ssh keypair

### Using VSCode on nemo

No VSCode on login node allowed! To use VSCode, you should grab an interactive node (max walltime = 3 days) as per the [CAMP docs](https://cegiwiki.crick.ac.uk/index.php/Running_jobs_on_CAMP).

3. From your terminal: `sbatch --part=ncpu --time=3-00:00:00 <(echo -e '#!/bin/bash\nsleep 3d')`

4. You can check the node assigned with `squeue -u <username>` under NODELIST

ex.


![image](https://github.com/McGranahanLab/Guidebook/assets/23587234/4df2f3d8-db5e-4873-b28c-e4350b0cd041)


5. Then, use remote ssh extension within VSCode and jump directly to your ineractive job. Your ssh config might look something like this: 

```
Host nemo_login
  HostName login.nemo.thecrick.org
  User harrigc
  ForwardAgent yes
  IdentityFile ~/.shh/id_rsa

Host nemo
  HostName ca124
  User harrigc
  ForwardAgent yes
  ProxyCommand ssh -W %h:%p nemo_login 
```

## Genomics England access (GEL) ##

Socialtails
------------

## Slack ##

## GitHub ##
If you're reading this, you're already in, yay!

## Zoom ##

## Important meetings ##

### Lab meetings ###

Other helpful information
------------
