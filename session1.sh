################################################################################
########### FastQC
################################################################################

mkdir ~/Desktop/FastQC
cd ~/Desktop/FastQC
ln -s ~/Desktop/rnaseqa/variant/Tumor_RNAseq_R1.fastq
ln -s ~/Desktop/rnaseqa/variant/Tumor_RNAseq_R2.fastq
fastqc Tumor_RNAseq_R1.fastq -o ~/Desktop/FastQC
fastqc Tumor_RNAseq_R2.fastq -o ~/Desktop/FastQC


################################################################################
########### Trimming
################################################################################

cd ~/Desktop
mkdir Trimming
cd Trimming

ln -s ~/Desktop/rnaseqa/variant/Tumor_RNAseq_R1.fastq
ln -s ~/Desktop/rnaseqa/variant/Tumor_RNAseq_R2.fastq

java -jar /usr/local/molbiocloud/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 4 Tumor_RNAseq_R1.fastq Tumor_RNAseq_R2.fastq Tumor_RNAseq_R1_pe.fq Tumor_RNAseq_R1_se.fq Tumor_RNAseq_R2_pe.fq Tumor_RNAseq_R2_se.fq ILLUMINACLIP:/usr/local/molbiocloud/Trimmomatic-0.39/adapters/TruSeq2-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:70


################################################################################
########### HISAT2
################################################################################

cd ~/Desktop
mkdir hisat
cd hisat
ln -s ~/Desktop/rnaseqa/tophat/* .

#3. Build index
hisat2-build genome.fa SpIndex
mkdir hisat_index
mv SpIndex* hisat_index/

#4. Alignment
hisat2 -p 8 --rna-strandness RF --dta -x hisat_index/SpIndex -p 8 -1 Sp_ds.left.fq.gz -2 Sp_ds.right.fq.gz -S Sp_ds.sam --summary-file Sp_ds_alignStats.txt

#6. Align all samples
!!:gs/ds/hs
!!:gs/hs/plat
!!:gs/plat/log

#7. Move aligned sam
mkdir Aligned_sam
mv *.sam Aligned_sam/

#8. Move alignment stats
mkdir AlignedStats
mv *.txt AlignedStats

#9. Convert sam to bam
mkdir Aligned_bam
samtools view -Su Aligned_sam/Sp_ds.sam | samtools sort - -o Aligned_bam/Sp_ds.sorted.bam

#10. Convert sam to bam for all other samples
!!:gs/ds/hs
!!:gs/hs/plat
!!:gs/plat/log

#11. Transcript assembly
stringtie Aligned_bam/Sp_ds.sorted.bam -p 8 --rf -o Assembled_transcripts/Sp_ds.gtf

!!:gs/ds/hs
!!:gs/hs/plat
!!:gs/plat/log

#12. Merge all transcript assemblies
ls Assembled_transcripts/*.gtf > mergelist.txt
cat mergelist.txt
stringtie --merge -p 8 -o stringtie_merged.gtf mergelist.txt

#13. Prep for ballgown
stringtie -e -B -p 8 -G stringtie_merged.gtf -o ballgown/Sp_ds/Sp_ds.gtf Aligned_bam/Sp_ds.sorted.bam
!!:gs/ds/hs
!!:gs/hs/plat
!!:gs/plat/log
