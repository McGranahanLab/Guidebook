#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/*
        Organization: UCL Cancer Institute
        Laboratory: Cancer Genome Evolution
        Authors: Maria Litovchenko
        Purpose: A simple script to show nextflow run in UCL cluster (SGE)
        Notes:
*/

params.refGenDir= file(params.refGen).getParent()

/* ----------------------------------------------------------------------------
* Help message
*----------------------------------------------------------------------------*/

// Help message
def helpMessage() {
        log.info """

        Nextflow test pipeline to demonstrate how to run it on UCL cluster.
        UCL cluster is managed by SGE. This pipeline downloads and indexes
        reference genome (hg19) with use of singularity container. The
        pipeline should be finished under 5 minutes. No input files required.

        nextflow main.nf --inventory --fastqDir -entry
        """
}

// Show help message
params.help = ''
if (params.help) {
    helpMessage()
    exit 0
}

/* ----------------------------------------------------------------------------
* Workflows
*----------------------------------------------------------------------------*/
workflow prepare_reference_genome {
        /*
                A workflow to download and index reference genome
        */

        download_reference_genome(params.refGen_link)
        index_reference_genome_samtools(download_reference_genome.out)
        index_reference_genome_bwa(download_reference_genome.out)
        index_reference_genome_picard(download_reference_genome.out)
}

/* ----------------------------------------------------------------------------
* Processes
*----------------------------------------------------------------------------*/
process download_reference_genome {
        /*
                Downloads reference genome
        */

        publishDir "${params.refGenDir}", pattern: '*sm.fa', mode: "copy",
                   overwrite: true
        tag { "download_reference" }
        label "S"

        input:
                val link_to_genome

        output:
                file "*sm.fa"

        shell:
        """
        wget ${link_to_genome}
        gunzip *

        refGene_fileName=`basename !{params.refGen}`
        echo \$refGene_fileName
        cat *.fa > \$refGene_fileName
        """
}

process index_reference_genome_samtools {
        /*
                Index reference genome with samtools
        */
        publishDir "${params.refGenDir}", pattern: "*.fai",
                   mode: "copy", overwrite: true
        tag { "index_reference_samtools" }
        label "M"
        input:
                path(path_to_genome)
        output:
                file "*.fai"

        script:
        """
        samtools faidx ${path_to_genome}
        """
}

process index_reference_genome_bwa {
        /*
                Index reference genome for use with BWA
        */
        publishDir "${params.refGenDir}", pattern: '*.{bwt,pac,ann,amb,sa}',
                   mode: "copy", overwrite: true
        tag { "index_reference_bwa" }
        label "XL"

        input:
                path(path_to_genome)
        output:
                tuple file("*.ann"), file("*.bwt"), file("*.pac"), file("*.sa"),
                      file("*.amb")

        script:
        """
        bwa index -a bwtsw ${path_to_genome}
        """
}

process index_reference_genome_picard {
        /*
                Index reference genome with picard
        */
        publishDir "${params.refGenDir}", pattern: "*.dict", mode: "copy"
        tag { "index_reference" }
        label "L"

        input:
                path(path_to_genome)
        output:
                file "*.dict"

        shell:
        '''
        refGene_fileName=$(basename !{path_to_genome})
        refGene_fileName=${refGene_fileName%.*}
        java -jar -XX:ParallelGCThreads=!{task.cpus} /bin/picard.jar \
                  CreateSequenceDictionary R=!{path_to_genome} \
                                           O=$refGene_fileName.dict
        '''
}

// inform about completition
workflow.onComplete {
    println "Pipeline completed at: $workflow.complete"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}

