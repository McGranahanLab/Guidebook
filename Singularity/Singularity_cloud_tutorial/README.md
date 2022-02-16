# Singularity cloud tutorial
This is a small tutorial showing how to build images in singularity cloud. The main advantage of this system is that you don't have to install anything on your computer to build an image. However, if you'd like to install singularity on your computer, follow this links: [Mac](https://singularity.lbl.gov/install-mac), [Linux](https://singularity.lbl.gov/install-linux), [Windows](https://singularity.lbl.gov/install-windows).

This tutorial also assumes that you're somewhat familiar with what singularity is _in general terms_. If you're not, here is a good [tutorial](https://singularity-tutorial.github.io/).

### Step 1
Go to [https://cloud.sylabs.io/](https://cloud.sylabs.io/) and register there. Using github account is recommended. Sign in.

### Step 2
Go to [https://cloud.sylabs.io/library](https://cloud.sylabs.io/library) and press on green button "Create container". Unfortunately, if you go to your own profile and will try to find a button with such functionality there, you won't. It's only accessible though the mentioned above link. 

### Step 3
In the fields "Container name" and "Description" put some dummy names. They are dummy because singularity cloud _always gives an error first time you fill them in_.

!["Step 1"](https://github.com/McGranahanLab/Wiki/blob/master/Singularity_cloud_tutorial/img/1.png)
The error will look like this:

!["Step 2"](https://github.com/McGranahanLab/Wiki/blob/master/Singularity_cloud_tutorial/img/2.png)
Now, after it gave you that error, you can put real values in fields "Container name" and "Description" :

!["Step 3"](https://github.com/McGranahanLab/Wiki/blob/master/Singularity_cloud_tutorial/img/3.png)

Press "Next"

### Step 4
Press on tab "Remote builder":

!["Step 4"](https://github.com/McGranahanLab/Wiki/blob/master/Singularity_cloud_tutorial/img/4.png)

In the text field, paste your recipe. This tutorial doesn't cover how to write a recipe, but there will be one! Also, this [link](https://singularity.lbl.gov/docs-recipes) provides a good overview of recipe structure. In addition, have a look at the [library of tested singularity recipies](https://github.com/McGranahanLab/bioinfcollab_cruklungcentre/tree/master/singularity_recipes).

!["Step 5"](https://github.com/McGranahanLab/Wiki/blob/master/Singularity_cloud_tutorial/img/5.png)

Fill in image tag and description and press "Build"

!["Step 6"](https://github.com/McGranahanLab/Wiki/blob/master/Singularity_cloud_tutorial/img/6.png)

Bulding will take some time. You can monitor the progress.

### Step 5
However, singularity _will never show you that the build was successfull, even if it was_. It's a bug. So, you need to look for "Creating SIF file...". If it's there, the build was successful. 

!["Step 7"](https://github.com/McGranahanLab/Wiki/blob/master/Singularity_cloud_tutorial/img/7.png)
Container is build!

### Step 6: getting container to your environment
#### Working with container on UCL server
Since singularity is installed on UCL server, you can simply press on "Show PULL CMD" button on the page of the created container, copy and paster the command in the terminal on UCL cluster, avoiding "--arc amd64", i.e `singularity pull --arch amd64 library://marialitovchenko/default/pyclone-vi:v1.0`. That's it!

!["Step 8"](https://github.com/McGranahanLab/Wiki/blob/master/Singularity_cloud_tutorial/img/8.png)
To run the container: `singularity exec <your_container.sif> <your_command>`

#### Working with container on GEL
In order to work with your container on GEL, you need first to pull it on your computer (can be done though UCL and then copied) and then submit it though airlock. You can only run containers on helix. To run container you need first to import singularity as module: `module load singularity/3.2.1` and then do `singularity exec <your_container.sif> <your_command>`. You can put `singularity exec <your_container.sif> <your_command>` command into any of your scripts and submit it as a job.
