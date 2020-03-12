######################################################
### DO NOT RUN THIS COMMAND!!!!
### THIS STEP HAS ALREADY BEEN COMPLETED FOR YOU!! ####
# mkdir GenomeIndexDir
# STAR --runMode genomeGenerate --genomeDir hg38IndexStar --genomeFastaFiles hg38IndexStarold/hg38.fa --runThreadN 16

## Create a working directory and change to that directory
mkdir ~/Desktop/Variant
cd ~/Desktop/Variant

## Symbolically link our first index
ln -s ~/Desktop/rnaseqa/variant/hg38IndexStar 

## This folder contains the output from the first pass of index-building
ls hg38IndexStar

## Make a directory called FirstAlign to store the output of first pass alignments
mkdir FirstAlign

## Make symbolic links to the two fastq files we will use for Today's work
ln -s ~/Desktop/rnaseqa/variant/Tumor_RNAseq_R1.fastq
ln -s ~/Desktop/rnaseqa/variant/Tumor_RNAseq_R2.fastq

## Generate first pass alignments using STAR
STAR --genomeDir hg38IndexStar --readFilesIn Tumor_RNAseq_R1.fastq Tumor_RNAseq_R2.fastq --runThreadN 8 --outFileNamePrefix ~/Desktop/Variant/FirstAlign/

## Please wait until the Alignment is finished and take a look at the 
## contents of FirstAlign directory and the Log.final.out file
ls FirstAlign/
less FirstAlign/Log.final.out

### DO NOT RUN THIS COMMAND!!!!
### THIS STEP HAS ALREADY BEEN COMPLETED FOR YOU!! ####
# mkdir hg38IndexStar2
# STAR --runMode genomeGenerate --genomeDir hg38IndexStar2 --genomeFastaFiles hg38IndexStar/hg38.fa --sjdbFileChrStartEnd FirstAlign/SJ.out.tab --runThreadN 16

## Symbolically link our second index
ln -s ~/Desktop/rnaseqa/variant/hg38IndexStar2

## Make a directory called SecondAlign to store the output of second pass alignments
mkdir SecondAlign

## Generate second pass alignments
STAR --genomeDir hg38IndexStar2 --readFilesIn Tumor_RNAseq_R1.fastq Tumor_RNAseq_R2.fastq --runThreadN 18 --outFileNamePrefix ~/Desktop/Variant/SecondAlign/

## Please wait until the Alignment is finished and take a look at the 
## contents of SecondAlign directory and the Log.final.out file
ls SecondAlign/
less SecondAlign/Log.final.out

## Take a look at the output alignments...
samtools view SecondAlign/Aligned.out.sam | less

## ...and the summary statistics of the alignments
samtools flagstat SecondAlign/Aligned.out.sam

## Add read group information using the Picard tool AddorReplaceGroups
picard AddOrReplaceReadGroups I=SecondAlign/Aligned.out.sam O=Tumor_rg_added_sorted.bam SO=coordinate RGID=123 RGLB=Truseq_SS_Paired RGPL=Illumina RGPU=Hiseq4000 RGSM=Tumor

## Take a look at the summary statistics of the output
## Did AddOrReplaceReadGroups step change the alignments?
samtools flagstat Tumor_rg_added_sorted.bam

## Marking duplicates
picard MarkDuplicates I=Tumor_rg_added_sorted.bam O=Tumor_dedupped_rg_added_sorted.bam CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=output.metrics

## Take a look at the summary statistics of the output
## Did MarkDuplicates step change the alignments?
samtools flagstat Tumor_dedupped_rg_added_sorted.bam

## SplitNCigarReads
export PATH=/usr/lib/jvm/java-1.8.0-openjdk-amd64/bin/:$PATH
gatk SplitNCigarReads -R ~/Desktop/rnaseqa/dbSNP/hg38.fa -I Tumor_dedupped_rg_added_sorted.bam -O Tumor_split.bam

## Base Recalibration - BaseRecalibrator to create the table
gatk BaseRecalibrator -R ~/Desktop/rnaseqa/dbSNP/hg38.fa -I Tumor_split.bam --known-sites ~/Desktop/rnaseqa/dbSNP/latest_db_snp.vcf.gz -O recal_data.table

## Base Recalibration - ApplyBQSR
gatk ApplyBQSR -R ~/Desktop/rnaseqa/dbSNP/hg38.fa -I Tumor_split.bam --bqsr-recal-file recal_data.table -output Tumor_recal_split.bam

## Variant calling! - HaplotypeCaller
gatk HaplotypeCaller -R ~/Desktop/rnaseqa/dbSNP/hg38.fa -I Tumor_recal_split.bam --dont-use-soft-clipped-bases -stand-call-conf 20.0 -O called_variants.vcf

## Variant Filtration
gatk VariantFiltration -R ~/Desktop/rnaseqa/dbSNP/hg38.fa -V called_variants.vcf -window 35 -cluster 3 --filter-name FS -filter "FS > 30.0" --filter-name QD -filter "QD < 2.0" -output filtered_called_variants.vcf

bcftools stats called_variants.vcf | less -s
bcftools stats filtered_called_variants.vcf | less -s

## ASE using GATK tool
gatk ASEReadCounter -R ~/Desktop/rnaseqa/dbSNP/hg38.fa -O ASE_counts.csv -I Tumor_recal_split.bam -V filtered_called_variants.vcf -min-depth 10 --min-mapping-quality 2
