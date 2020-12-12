#!/bin/sh

##########################################################################################
# bgc_tools                                                                              #
# File: bgcInstaller.sh                                                                  #
  VERSION="v1.0.1"                                                                       #
# Author: Justin C. Bagley                                                               #
# Date: created by Justin Bagley on Wed, Oct 2 14:24:59 CDT 2019                         #
# Last update: December 12, 2020                                                         #
# Copyright (c) 2019-2020 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <jbagley@jsu.edu>.                                               #
#                                                                                        #
# Description:                                                                           #
# SCRIPT THAT AUTOMATES DOWNLOAD AND INSTALL OF THE SOFTWARE PROGRAM BGC (FOR BAYESIAN   #
# GENOMIC CLINE ANALYSIS) ON A UNIX/LINUX MACHINE                                        #
#                                                                                        #
##########################################################################################

if [[ "$1" == "-V" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename "$0") $VERSION";
	exit
fi

echo "
##########################################################################################
#                           bgcInstaller v1.0.1, December 2020                           #
##########################################################################################"

######################################## START ###########################################
## OUTPUT

# exec >> ./bgc_installer_log.out.txt
# exec 2>&1

## idea for selectively logging output to file (from URL: https://stackoverflow.com/questions/18311436/start-and-stop-logging-terminal-output-to-file-from-within-bash-script):
# {
#  echo "aaa"
#  echo "bbb"
#  echo "ccc"
# } 2>&1 | tee logfile.log

## DOWNLOAD BGC

cd ~ ;

if [[ ! -s bgcdist1.03.tar.gz ]]; then
	echo "$(date)  Downloading bgc v1.03 distribution (tarball) from the web... "
	curl -O -J -L https://sites.google.com/site/bgcsoftware/home/bgcdist1.03.tar.gz?attredirects=0&d=1  ;
	sleep 60 ;
	echo ""
fi

if [[ -s ./bgcdist1.03.tar.gz ]]; then
	echo "$(date)  Found bgc tarball in place. Unzipping... "
	tar -xzvf bgcdist1.03.tar.gz ;
	cd bgcdist/ ;
	echo ""
	echo "$(date)  Moving into bgcdist/ directory... "
	echo ""
else 
	echo "$(date)  Curl download failed. Quitting..."  ;
	exit 1  ;
fi

## INSTALL BGC

echo "$(date)  Checking and fixing clang / clang++ ... "

MY_CLANG_PLUS_NAME="$(ls -l $(which clang)* | grep '++' | sed 's/.*\ .*\ \/.*\///g; s/\ //g')" ;
sed -i.bak 's/x86\_64\-apple\-darwin13\.4\.0\-clang++/'"$MY_CLANG_PLUS_NAME"'/g' "$(which h5c++)" ;
echo ""

MY_CLANG_NAME="$(ls -l $(which clang)* | grep -v '++' | sed 's/.*\ .*\ \/.*\///g; s/\ //g')" ;
sed -i.bak 's/x86\_64\-apple\-darwin13\.4\.0\-clang/'"$MY_CLANG_NAME"'/g' "$(which h5cc)" ;
echo ""

echo "$(date)  Compiling bgc for your machine... "
# Compile bgc:
h5c++ -Wall -O2 -o bgc bgc_main.C bgc_func_readdata.C bgc_func_initialize.C bgc_func_mcmc.C bgc_func_write.C bgc_func_linkage.C bgc_func_ngs.C bgc_func_hdf5.C mvrandist.c -lgsl -lgslcblas
ls -l ./bgc* ;
echo ""

echo "$(date)  Compiling estpost utility program for your machine... "
# Compile estpost utility program:
h5cc -Wall -O3 -o estpost estpost_h5.c -lgsl -lgslcblas
ls -l ./estp* ;
echo ""


echo "$(date)  Finishing bgc install, with your sudo permission :) ... "
# Finish install:
chmod u+x bgc estpost ;
sudo cp bgc estpost /usr/bin/ ;


## CHECK BGC
cd ..;

echo "$(date)  Checking to see whether bgc is working on your machine... "
echo "$(date)  Testing... testing... 1... 2... 3... "

bgc -h ;

estpost -h ;

echo " Finished downloading and compiling bgc and related utility program estpost on your local machine using bgcInstaller (bgc_tools). "
echo " Bye."
#
#
#
######################################### END ############################################

exit 0
