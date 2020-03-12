## go to and make the folder of scripts transferred to Github as the present
## working directory (pwd)
## list all files within the folder
ls

## initiate a new local Directory (under pwd) as an empty Git Repository
git init
## after hit Return, the screen should show "Initialized empty Git repository
## in PATH_pwd/.git/"

## add files of scripts in the original folder to the empty new Git Repository  
## and script files are now staged for their 1st "Commit"
git add .

## review to confirm all files have been added to local Git repository and 
## staged to be ready for "commit" (not committed yet) 
git status

## commit the files that have been added/staged in the local Git Repository
git commit -m "name_for_files"
## "name_for_files" is a casual name made up for all the files transferred

## specify the remote Git Repository where the files in local Git repository
## will be pushed to by copying its URL
git remote add origin https://github.com/wendyy11212/NIH_RNASEQ_WORKSHOP_03.20.git

## push files from the local Git Repository to Github (remote Git Repository)
git push -u origin master

## enter username and password when asked to complete the transfer of files
## of scripts to Github


