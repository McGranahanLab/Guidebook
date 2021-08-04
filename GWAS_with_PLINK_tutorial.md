# GWAS with PLINK: a tutorial

- [GWAS with PLINK: a tutorial](#gwas-with-plink--a-tutorial)
  * [Intro](#intro)
  * [Input files](#input-files)
    + [Ped file](#ped-file)
    + [Map file](#map-file)
    + [Phenotype file](#phenotype-file)
    + [Covariate file](#covariate-file)
  * [GWAS](#gwas)
      - [Step 1: create ped and map files from VCF](#step-1--create-ped-and-map-files-from-vcf)
      - [Step 2: pruning of the variants](#step-2--pruning-of-the-variants)
      - [Step 3: cutoff on MAF and genotyping rate](#step-3--cutoff-on-maf-and-genotyping-rate)
      - [Step 4: running PLINK](#step-4--running-plink)
      - [Step 4: multiple test corrections via permutations](#step-4--multiple-test-corrections-via-permutations)
      - [Step 5: annotate significant variants](#step-5--annotate-significant-variants)

*A small note for the reader: there are couple of references to Drosophila here, because the author of this tutorial used to do GWAS on fruit flies.*

## Intro
Plink is a free and the most used software for conducting GWAS. It fully operates through the command
line and can compute a 1 phenotype association to a cohort of _Drosophila_ samples under several 
minutes.
 
In a nutshell, GWAS associates genotypes with phenotypes, thus, we will need 2 mandatory data inputs, 
such as variant file (aka VCF) and phenotype file. Covariates can be optionally supplemented via one 
more, 3rd file. Unfortunately, PLINK does not take VCF as an input, but has its own input format:

* `.ped` file which contains information on the individuals and their genotypes
* `.map` file which contains information on the genetic markers
Classically for PLINK, the phenotype is actually written in the ped file, but I do not do that because 
usually I test a lot of phenotypes. In such case I put phenotypes in the separate file. Both ped and 
map files are in fact usual text files, they are rather big. As usual, a compression to binary file 
can be applied, then PLINK will require 3 binary files as an input: a 
* `.bed` binary file that contains individual identifiers (IDs) and genotypes 
* `.fam` text file that contain information on the individuals
* `.bim` text file that contain information on the genetic markers

Because reading large text files can be time‐consuming, it is recommended to use binary files. However,
I prefer not binary ped and map files in my practice. Let’s consider ped and map formats now.

## Input files
### Ped file
The PED file is a white-space (space or tab) delimited file without header. The first six columns are
mandatory:

| Family        | ID           | Individual ID  | Paternal ID| Maternal ID|Sex (1 = F, 2= M)|Phenotype|
| ------------- |:-------------:| -----:|-----:|-----:|-----:|-----:|

Specifications:
* the combination of family and individual ID should uniquely identify a person
* PED file must have 1 and only 1 phenotype in the sixth column
* phenotype can be either a quantitative trait or an affection status, PLINK will automatically detect the type. **Missing value for phenotype by default is -9.**
* **Quantitative traits with decimal points must be coded with a period/full-stop character and not a comma**, i.e. 2.394 not 2,394
* If an individual's sex is unknown, then any character other than 1 or 2 can be used. However, these individuals will be dropped from any analyses. To disable the automatic setting of the phenotype to missing if the individual has an ambiguous sex code, add the --allow-no-sex option
* Other phenotypes can be swapped in by using the --pheno (and possibly --mpheno) option, which specify an alternate phenotype is to be used
 
Then, the columns 7 and onwards contain genotypes of the individuals. The genotypes can be coded by
any character (e.g. 1,2,3,4 or A,C,G,T or anything else) except 0 which is, by default, the missing 
genotype character. All markers should be biallelic. ALL SNPs (whether haploid or not) must have two alleles specified. 
  
Example of the ped file:
| Family        | ID           | Individual ID  | Paternal ID| Maternal ID|Sex|Phenotype|SNP1_A1|SNP1_A2|SNP2_A1|SNP2_A2|SNP3_A1|SNP3_A2|
| ------------- |:-------------:| -----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|
|FAM001|1|0|0|0|1|2|A|G|G|G|A|C|
|FAM001|2|0|0|1|2|2|A|A|A|G|0|0|

Note: The header isn’t usually present in the file. If you want it in the file, put # in the beginning of the line. Most of the times I put dummy phenotype inside ped, because I need to test many phenotypes and it’s easier to supplement them though a separate file.

### Map file
Map file contains information on the name and position of the variants in the ped file. 
It is again a white-space (space or tab) delimited file without header. There are 4 columns in it:
 
|Chromosome|VariantID|Position in morgans|Base pair coordinate|
|-----:|-----:|-----:|-----:|
 
Specifications:
* position in morgans = physical position of the variant. It is safe to use dummy value of `0` instead of position in morgans
* The autosomes should be coded 1 through 22. In Drosophila, I usually replace chr2L with chr1, chr2R with chr2, etc.
* The order of the variants in this file should follow the order of the variants in ped file
* The following other codes can be used to specify other chromosome types:
```
    X    X chromosome                    -> 23
    Y    Y chromosome                    -> 24
    XY   Pseudo-autosomal region of X    -> 25
    MT   Mitochondrial                   -> 26
 ```
Example of map file:
  
|Chromosome|VariantID|Position in morgans|Base pair coordinate|
|-----:|-----:|-----:|-----:|
|chr1|SNP1|1000|3556|
|chr2|SNP2|8689|10595|
|chr3|SNP3|7897|12598|

Note: The header isn’t usually present in the file. If you want it in the file, put # in the beginning of the file. 

### Phenotype file
Phenotype file contains information about phenotype values in the individuals from ped file, it’s tab
or space delimited. There are 2 columns which define sample and one column per phenotype. Phenotypes 
can be binary or continuous. One can mix phenotypes of different types in the same file, i.e. phenotype #1 
can be continuous and phenotype #2 can be binary. **The header is present in the file.**
 
|FamilyID|IndividualID|PhenotypeID_1|PhenotypeID_2|
|-----:|-----:|-----:|-----:|
 
Example of phenotype file:
 
|FamilyID|IndividualID|PhenotypeID_1|PhenotypeID_2|
|-----:|-----:|-----:|-----:|
|FAM001|1|female|0.46464|
|FAM001|2|male|0.6353|

### Covariate file
There is a possibility to supply PLINK with covariates measured for the study. The file is a 
tab/space delimited table with the header. Example:

|FamilyID|IndividualID|Age|BMI|
|-----:|-----:|-----:|-----:|
FAM001|1|40|20|
FAM001|2|35|17|

## GWAS 
Now, then we know all file formats, we can perform GWAS. I assume that you have vcf file with variants, phenotype file with the phenotypes you would like to test and a table with covariates (optional). Also, phenotype and covariate file should be formatted as described above. 
#### Step 1: create ped and map files from VCF
To do so, vcftools are used:
``` 
vcftools --vcf input.vcf  --plink  --out plink_input_from_vcf
```
This will create the map and ped files which will be used in the following steps. 
Or directly in PLINK: 
``` 
plink --vcf input.vcf  --allow-extra-chr  --out plink_input_from_vcf
```
This will create a binary bed, fam, bim files. I prefer vcftools. In case you prefer to work with binary 
files, always write `--bfile` instead of `--file` in all commands below.

####  Step 2: pruning of the variants
Variants which are in LD will inflate p-values of the association and thus are needed to be pruned:
```
plink --file plink_input --indep-pairwise 500 5 0.2 --allow-extra-chr 
```
`--indep-pairwise` requires three parameters: 
* a window size in variant count or kilobase (if the 'kb' modifier is present) units
* a variant count to shift the window at the end of each step
* a pairwise r2 threshold: at each step, pairs of variants in the current window with squared correlation greater than the threshold are noted, and variants are pruned from the window until no such pairs remain.

`--allow-extra-chr` allow non-conventional chromosome names.

This command will produce 2 files: plink.prune.in and plink.prune.out. The first file will contain 
variants which survived pruning, and the second one will contain variants which didn’t. However, 
both types of variants, pruned or not, are still in the plink_input.ped. In fact, it wasn’t touched.
Let’s remove them now:

```
plink --file  plink_input 
         --exclude plink.prune.out 
         --allow-extra-chr --recode --out plink_input_pruned
 ```

`--exclude` allows to exclude variants listed in plink.prune.out. This command will create new map and ped files plink_input_pruned.map and plink_input_pruned.ped.

#### Step 3: cutoff on MAF and genotyping rate
Usually we are not interested in testing rare variants, thus they needed to be removed. The cutoff on MAF depends 
on the size of the dataset, i.e. for the 100 individuals minimal MAF would be 0.05, but for 1000 it can be 0.01. 
We will also filter out all variants which have low genotyping rate. 
```
plink --file plink_input_pruned 
         --allow-extra-chr  
         --maf 0.05 
         --geno 0.2 --recode --out plink_input_pruned_maf
```
`--maf` minimal minor allele frequency for the variant to be included

`--geno` filters out all variants with missing call rates exceeding the provided value

####  Step 4: running PLINK
Finally, we can run detection of associations
```
plink --file plink_input_pruned_maf --assoc 
         --pheno phenotype.txt --all-pheno 
         --covar covariates.txt 
         --allow-no-sex 
         --missing-phenotype MG 
         --adjust
         --allow-extra-chr --out plink_result
```
`--assoc` basic association test (Chi-square). It’s also possible to have --model (Cochran-Armitage trend test or Genotypic (2 df) test or Dominant gene action (1df) test or Recessive gene action (1df) test), --fisher (Fisher test), --linear (linear regression) and --logistic (logistic regression) instead of --assoc. 
`--pheno` path to the phenotype file
`--all-pheno` tells PLINK that all phenotypes in the pheno file should be tested
`--covar` path to covariate file (optional)
`--allow-no-sex` by default, PLINK will exclude individuals, for which sex is unknown, this option will prevent it from doing it
`--missing-phenotype` supply to PLINK a code for the missing phenotype. By default it’s -9.
`--adjust` adjust p-values for multiple testing. In case of multiple phenotype usage, it will not correct for multiple phenotypes.

As a result, there will be 1 file per phenotype with the extension .assoc, with the following columns in case `--assoc` was used:

|CHR|SNP|BP|A1|F_A|F_U|A2|CHISQ|P|OR|
|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|
|Chromosome|SNP ID|Physical position (base-pair)|Minor allele name (based on whole sample)|Frequency of this allele in cases|Frequency of this allele in controls|Major allele name|Basic allelic test chi-square|P-value (unadjusted)|odds ratio|

In case other test is used (`--model` /  `--fisher` /  `--linear`  / `--logistic`) the output will
also be a table, but the column names will be different. One can check out all the possible output 
tables here.

The adjusted p-value will be output to the separate file with the following columns

|CHR|SNP|UNADJ|GC|BONF|HOLM|SIDAK_SS|SIDAK_SD|FDR_BH|FDR_BY|
|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|
|chromosome|SNP ID|Unadjusted p-value|Genomic-control corrected p-values|Bonferroni adjusted p-values|Holm adjusted p-values|Sidak single-step adjusted p-values|Sidak step-down adjusted p-values|Benjamini & Hochberg step-up FDR control|Benjamini & Yekutieli step-up FDR control|

####  Step 4: multiple test corrections via permutations
Permutation procedures provide a computationally intensive approach to generating significance levels 
empirically. Such computations might be needed then you have doubts about normality of phenotype 
distributions, about fulfillment of any other test assumptions or have small sample size. 

There are 2 ways to do permutations in PLINK: adaptive vs max(T). 
* In adaptive permutation approach, PLINK gives up permuting SNPs that are clearly going to be non-significant more quickly than SNPs that look interesting. In other words, if after only 10 permutations it sees that for 9 of these the permuted test statistic for a given SNP is larger than the observed test statistic, there is little point in carrying on, as this SNP is unlikely to ever achieve a highly significant result. This greatly speeds up the permutation procedure. 
* In contrast, max(T) permutation does not drop SNPs along the way. If 1000 permutations are specified, then all 1000 will be performed, for all SNPs. The benefit of doing max(T) is that two sets of empirical significance values can then be calculated - pointwise estimates of an individual SNPs significance, but also a value that controls for that fact that thousands of other SNPs were tested. 

In order to run PLINK with adaptive permutations, replace `--adjust` with `--perm`, and replace with `--mperm 1000` to do 1000 max(T) permutations. 
In case of adaptive permutations, new file will be created, with the `.perm` extension:

|CHR|SNP|STAT|EMP1|NP|
|-----:|-----:|-----:|-----:|-----:|
|Chromosome|SNP ID|Test statistic|Empirical p-value|Number of permutations|


In case of max(T) permutations, new file will be created, with the `.mperm` extension:

|CHR|SNP|STAT|EMP1|EMP2|
|-----:|-----:|-----:|-----:|-----:|
|Chromosome|SNP ID|Test statistic|Empirical p-value (pointwise)|Corrected empirical p-value (max(T) / familywise)|

#### Step 5: annotate significant variants
Once you found out significant variants you can extract them from the vcf you used for PLINK 
with vcftools and them annotate them with snpEff. It’s a command line tool:
```
java -jar snpEff.jar BDGP6.82 sinificant_GWAS.vcf > sinificant_GWAS.annot.vcf 
```
The database (BDGP6.82) will be dependent on the organism


P.S. A good paper - tutorial on PLINK: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6001694/

And example usage of PLINK on HapMap project: http://zzz.bwh.harvard.edu/plink/tutorial.shtml

P.P.S. It’s really a basic tutorial, I didn't touch on population stratification, etc, mainly because I don’t do it myself.
