#create a working directory
mkdir dapars

#Change directory to your dapars folder
cd dapars

#Link the test dataset to your dapars folder
ln -s ~/Desktop/rnaseqa/apa/* .

#make sure you have the necessary files
#Look at the contents of the wig files, UTR file, refseq id file, gene bed file.
ls

#Run DaPars
#install older version of rpy2
python2 /usr/local/molbiocloud/dapars-0.9.1/src/DaPars_main.py DaPars_test_data_configure.txt 

#visualize a significantly differentially expressed alternative polyadenylation usage using igv

