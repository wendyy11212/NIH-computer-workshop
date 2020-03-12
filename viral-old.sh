#make working directory
mkdir viral
#change to the viral directory
cd viral

#link input files
ln -s ~/Desktop/rnaseqa/vfs/* .
#make sure all required files are in there
#look at the input files and their content
ls

#Run Viral Fusion Search
viral.fusion.pl --config vfs.conf --insertSIZE 350 HKCI5a_gz CL7R_1_VFS.fq.gz CL7R_2_VFS.fq.gz

bowtie-build GRCh38.p12.genome.fa GRCh38.p12.genome

python VirTect.py -t 12 -1 ~/Downloads/test_R1.fq.gz -2 ~/Downloads/test_R2.fq.gz -o Test2 -ucsc_gene human_reference/gencode.v29.annotation.gtf -index human_reference/GRCh38.p12.genome -index_vir viruses_reference/viruses_757.fasta -d 200


