# Newcomers guide

Welcome to Nicholas McGranahan lab! We compliled a short guide for you to help you with the overwhelming amount of information you might face upon your arrival. We are a bioinformatics lab and therefore are working on several computational servers: UCL, CAMP (Crick institute) and GEL (Genomics England). TRACERx data for now are located at CAMP, but we are working on moving them to UCL.

Below you can find a quick guide to how to get access to the various clusters / social platforms / etc.

UCL email address
------------

Computational clusters
------------

### How to: get access to UCL cluster  ###
Sometimes you want numbered lists:

1. Get your computer science (CS) account here: https://tsg.cs.ucl.ac.uk/apply-for-an-account/. Put Nicholas McGranahan as “Dept. of Computer Science Sponsor”. It will take a couple of days to get an answer. Also, you should have a cell phone so they could text you the password.
2. After you have your computer science account, apply for a computer science cluster account: https://hpc.cs.ucl.ac.uk/account-form/. Do not fill in “Machine IP” or “Software requirements” fields
3. In meantime, you can read carefully a user guide to the HPC here: https://hpc.cs.ucl.ac.uk/ (username: hpc, password: comic)
4. Once you have your cluster account, you can apply for storage space for your project, if known and needed, here: https://hpc.cs.ucl.ac.uk/storage-form/

Before accessing to the server, please read this: https://hpc.cs.ucl.ac.uk/quickstart/ and this https://hpc.cs.ucl.ac.uk/full-guide/. We usually use `gamble `for our computations.

To test your connection to the server, type in your terminal:

```
ssh <your user name>@storm.cs.ucl.ac.uk # use your CS account password
ssh <your user name>@gamble.cs.ucl.ac.uk # use your CS account password
```

Congrats! You’re on the cluster.

Our main folder is accessible via : `cd /SAN/mcgranahanlab/general/`. Once you’re in, please create a folder for yourself: `mkdir your_name`. Please be aware that we should only store scripts in that folder, and no data. To store data, request storage space for your project, see point 4 above.

You can list all the available software here:  `ll /share/apps/`, and genomics-specific like this: `ll /share/apps/genomics/`

Ed Martin (`e.martin@cs.ucl.ac.uk`) is our contact for the cluster questions, he’s very responsive. But please don’t abuse this link: first ask people in the lab.

### Crick cluster access (CAMP) ###

### Genomics England access (GEL) ###

Social
------------

### Slack ###

### GitHub ###
If you're reading this, you're already in, yay!

### Zoom ###

### Important meetings ###

#### Lab meetings ####

Other helpful information
------------
