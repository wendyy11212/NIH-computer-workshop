#create and change to a working directory
mkdir sra
cd sra

#Download the sra (SRR390728)
prefetch -a "/usr/local/molbiocloud/aspera/cli/bin/ascp|/usr/local/molbiocloud/aspera/cli/etc/asperaweb_id_dsa.openssh" SRR390728

#read statistics
sra-stat --quick --xml SRR390728

#extract fastq data
fasterq-dump SRR390728

#dump SAM alignment from the sra file and write it in BAM format
sam-dump SRR390728 | samtools view -bS - > SRR390728.bam

#index and Visualize the dumped bam file using the below command;
samtools index SRR390728.bam
igv
#in igv look for position 1:89051831

