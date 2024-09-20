#!/bin/bash
set -e

# Pull latest images
docker-compose -f docker-compose.rna-seq.yml pull

# Download data
docker-compose -f docker-compose.rna-seq.yml run sra-tools fastq-dump --split-files $SRA_ACCESSION

# Run FastQC
docker-compose -f docker-compose.rna-seq.yml run fastqc fastqc /data/*.fastq -o /data/fastqc_results

# Run Trimmomatic
docker-compose -f docker-compose.rna-seq.yml run trimmomatic trimmomatic PE /data/input_1.fastq /data/input_2.fastq /data/output_1.fastq /data/output_1_unpaired.fastq /data/output_2.fastq /data/output_2_unpaired.fastq ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# Run STAR alignment
docker-compose -f docker-compose.rna-seq.yml run star STAR --genomeDir /data/genome --readFilesIn /data/output_1.fastq /data/output_2.fastq --outFileNamePrefix /data/aligned_

# Run HTSeq
docker-compose -f docker-compose.rna-seq.yml run htseq htseq-count -f bam -r pos /data/aligned_Aligned.out.sam /data/genes.gtf > /data/counts.txt

# Run DESeq2
docker-compose -f docker-compose.rna-seq.yml run deseq2 Rscript /scripts/run_deseq2.R
