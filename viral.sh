#make working directory
mkdir ~/Desktop/viral

#change to the viral directory
cd ~/Desktop/viral

#link input files
ln -s /usr/local/molbiocloud/VirTect/* .

#make sure all required files are in there
#look at the input files and their content
ls

#Run Viral Fusion Search
python2 VirTect.py \
-t 12 \
-1 CL7R_1_VFS.fq.gz \
-2 CL7R_2_VFS.fq.gz \
-o CLR \
-ucsc_gene human_reference/gencode.v29.annotation.gtf \
-index human_reference/GRCh38.p12.genome \
-index_vir viruses_reference/viruses_757.fasta \
-d 200


