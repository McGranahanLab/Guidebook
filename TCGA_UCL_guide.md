# Guide to using the TCGA data on the UCL cluster


## Access

First step for access is to apply for a UCL CS computer cluster account. The form to apply can be found [here](https://hpc.cs.ucl.ac.uk/account-form/).

Once you have a computer cluster account you should have access to the UCL computer cluster via a login node such as gamble (gamble.cs.ucl.ac.uk). The TCGA data is however only accessible from a secure login node called barker (barker.cs.ucl.ac.uk). Access to this requires two factor authentication and permissions to be added to the correct groups. This can be done if you contact Ed Martin <ed.martin@cs.ucl.ac.uk>. 


## Data location

Once you have ssh-ed into gamble and then barker and completed the two factor authentication, the TCGA data can be found at the following locations:

/SAN/colcc/TCGA/

All data folders are automatically hidden until you attempt to cd into them at which point they are automatically mounted. A list of all available data sets is as follows:

* WXS-LUAD
* WXS-LUSC
* WXS-SKCM
* WXS-GBM
* WXS-LGG
* WXS-UVM
* WXS-BLCA
* WXS-BRCA
* WXS-ESCA
* WXS-ACC
* WXS-HNSC
* WXS-OV
* RNAseq-LUAD
* RNAseq-LUSC
* RNAseq-SKCM
* RNAseq-GBM
* RNAseq-LGG
* RNAseq-UVM
* RNAseq-BLCA
* RNAseq-BRCA
* RNAseq-BRCA_legacy
* RNAseq-ESCA
* RNAseq-ACC
* RNAseq-HNSC
* RNAseq-OV
* WXS-CESC
* WXS-CHOL
* WXS-COAD
* WXS-DLBC
* WXS-KICH
* WXS-KIRC
* WXS-KIRP
* WXS-LAML
* WXS-LIHC
* WXS-MESO
* WXS-PAAD
* WXS-PCPG
* WXS-PRAD
* WXS-READ
* WXS-SARC
* WXS-STAD
* WXS-TGCT
* WXS-THCA
* WXS-THYM
* WXS-UCEC
* WXS-UCS
* RNAseq-CESC
* RNAseq-CHOL
* RNAseq-COAD
* RNAseq-DLBC
* RNAseq-KICH
* RNAseq-KIRC
* RNAseq-KIRP
* RNAseq-LAML
* RNAseq-LIHC
* RNAseq-MESO
* RNAseq-PAAD
* RNAseq-PCPG
* RNAseq-PRAD
* RNAseq-READ
* RNAseq-SARC
* RNAseq-STAD
* RNAseq-TGCT
* RNAseq-THCA
* RNAseq-THYM
* RNAseq-UCEC
* RNAseq-UCS


## BAM files and permission issues

You may not automatically be given permission to access the entire TCGA data base and may need to contact Ed Martin to ensure you have access to all the data you need.

### WXS data

There is some variability in the format of each WXS folder. For WXS-LUAD and WXS-LUSC the bam files for the samples are within the **data/** subfolder with each sample being separated within an individual folder. The WXS-BRCA data set meanwhile has all the bam files together within the **data/** subfolder with no additional organisation. A list of all the locations of the bam files for all cohorts is in the process of being created.

#### Accessing encrypted data
Some WXS cohorts such as WXS-SKCM have the data encrypted within the **data-enc/** subfolder, with the **data/** folder being empty. To mount the unencrypted data set the following steps should be taken:


* Add the encryption program to your path
		
		source /share/apps/slade/source_files/gc.source 
* From within the folder e.g. /SAN/colcc/TCGA/WXS-SKCM/ type:
		
		gocryptfs data-enc data
* At this point you will be required to type the TCGA associated password and the **data/** folder should be mounted
* To unmount the folder when no longer required type:
		
		fusermount -u /SAN/colcc/TCGA/WXS-SKCM/data

***NOTE 22nd September 2020***: At present the above way of accessing encrypted data does not work due to a permission issue with the file data-enc/gocryptfs.conf and the password needed not being known. These issues will hopefully be resolved soon. Additionally these encryptic cohorts at some point will be changed to the same format as the WXS-LUAD and WXS-LUSC cohorts so that these above steps will not be required.


### RNAseq data

TBD

## Useful scripts

TBD




