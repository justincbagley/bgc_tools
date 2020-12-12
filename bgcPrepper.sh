#!/bin/sh

##########################################################################################
# bgc_tools                                                                              #
# File: bgcPrepper.sh                                                                    #
  version="v0.1.4"                                                                       #
# Author: Justin C. Bagley                                                               #
# Date: created by Justin Bagley on July 5, 2017                                         #
# Last update: December 12, 2020                                                         #
# Copyright (c) 2017-2020 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# SHELL SCRIPT FOR AUTOMATING PREPARATION OF BGC INPUT FILES FROM PLINK PED-FORMATTED    #
# PARENTAL (P1, P2) AND ADMIXED POPULATION SNP DATA FILES                                #
#                                                                                        #
##########################################################################################

echo "
##########################################################################################
#                            bgcPrepper v0.1.4, December 2020                            #
##########################################################################################"

######################################## START ###########################################

##--Script takes as input three PLINK PED-formatted files created by converting from vcf to
##--PLINK in vcftools, separately for p1, p2, and admixed individuals. In other words, make
##--the input file by splitting your original vcf datafile into three separate PED-formatted
##--files in vcftools. Specifically do this using the --keep and/or --indv, --recode/--012,
##--and --plink options within vcftools. Once these files are in hand, simply place them into
##--the current working directory where the bgcPrepper shell script is located and run the
##--prepper analysis from the command line using $ ./bgcPrepper.sh.

echo "INFO      | $(date) | STEP #1: SETUP. " 
###### Set paths and filetypes as different environmental variables, and make calc:
	MY_PATH=`pwd -P`
	echo "INFO      | $(date) |          Setting working directory to: $MY_PATH "
	calc () {
	bc -l <<< "$@" ;
}


echo "INFO      | $(date) | STEP #2: READ INPUT FILES AND SAVE INFO ON THEIR CHARACTERISTICS. "
echo "INFO      | $(date) |          Reading in input parental and admixed file(s)... "
### Read in the P1, P2, and admixed file(s), by getting filenames matching appropriate 
##--name patterns. Then count number (n) columns in each file, which should be identical, 
##--since the columns should reflect equal #s of SNPs, with 1 column per SNP.

	MY_P1_FILE="$(find . \( -name "P1*txt" -o -name "p1*txt" -o -name "*p1*" \) -type f | sed 's/\.\///g')";
	MY_P2_FILE="$(find . \( -name "P2*txt" -o -name "p2*txt" -o -name "*p2*" \) -type f | sed 's/\.\///g')";
	MY_ADMIXED_FILE="$(find . \( -name "Admix*txt" -o -name "admix*txt" -o -name "*Admix" -o -name "*admix" \) -type f | sed 's/\.\///g')";

	##--Get n columns in each file:
	MY_N_P1_COL="$(calc $(head -n1 "$MY_P1_FILE" | grep -o "\t" | wc -l))";
	MY_N_P2_COL="$(calc $(head -n1 "$MY_P2_FILE" | grep -o "\t" | wc -l))";
	MY_N_ADMIX_COL="$(calc $(head -n1 "$MY_ADMIXED_FILE" | grep -o "\t" | wc -l))";


echo "INFO      | $(date) | STEP #3: CLEAN UP, CREATE HEADLESS FILES CONTAINING ONLY DATA MATRICES. "
echo "INFO      | $(date) |          Removing header rows and columns, and saving backup files ('-e' extension)... "
	##--Remove row headers (first two columns of data, which contain sample popname and
	##--ID):
	perl -i -pe 's/^[A-Z]{2,}\t[A-Z\_0-9]*\t//g' "$MY_P1_FILE" ;
	perl -i -pe 's/^[A-Z]{2,}\t[A-Z\_0-9]*\t//g' "$MY_P2_FILE" ;
	perl -i -pe 's/^[A-Z]{2,}\t[A-Z\_0-9]*\t//g' "$MY_ADMIXED_FILE" ;

	##--Also remove header/first line from each file using sed, and create and move sed "-e"
	##--files to folder (in case they are needed later).
	sed -i -e "1d" "$MY_P1_FILE" ;
	sed -i -e "1d" "$MY_P2_FILE" ;
	sed -i -e "1d" "$MY_ADMIXED_FILE" ;

	mkdir backup_files
	mv ./*-e ./backup_files/ ;


echo "INFO      | $(date) | STEP #4: SPLIT EACH COLUMN/SNP IN THE P1, P2, and admixed FILES OUT INTO A NEW FILE, WHILE "
echo "INFO      | $(date) |          KEEPING SNPs FROM EACH INPUT FILE TYPE TOGETHER, AND GIVING CORRESPONDING FILES MATCHING "
echo "INFO      | $(date) |          NAMES INDICATIVE OF FILE OF ORIGIN. "
echo "INFO      | $(date) |          Separating P1, P2, and admix files into 1 file per column/SNP... "
	##--Do the cutting and separating into 1 file per column/SNP. If file size for X# of
	##--the output SNP (single column) files is equal to the number of rows in the same 
	##--file, then there has been an error because the number of columns fed to the loop 
	##--is X# too big. For example, this will cause a single resulting P1 locus file (e.g. 
	##--"P1_locus4858.txt") to contain the same number of rows as the number of P1 individuals,
	##--but contain no SNP info; hence file size, calculated in bytes, will equal the number
	##--of rows. This test removes files that are not empty but contain only rows or tabs,
	##--and no SNP information.
	#
	##--Idea for using echo -e to add locus number to first line of every SNP file came from
	##--the following URL: https://superuser.com/questions/246837/how-do-i-add-text-to-the-beginning-of-a-file-in-bash
	#
	##--For 5K SNPS, this produces 5K files per P1, P2, and admixed file, for a total of ~15K 
	##--files, and could possibly be a little slow... but it gets the job done right. 
echo "INFO      | $(date) |          Splitting P1 group SNPs out to separate files... "
	(
		for (( i=1; i<=$MY_N_P1_COL; i++ )); do
			cut -f"$i" "$MY_P1_FILE" > P1_locus"$i".txt ;
			FILE=P1_locus"$i".txt
			FILE_SIZE="$(wc -c P1_locus$i.txt | sed 's/\.\///g; s/P1.*//g')"
			FILE_NLINES="$(wc -l P1_locus$i.txt | sed 's/\.\///g; s/P1.*//g')"
			if [[ "$FILE_SIZE" -eq "$FILE_NLINES" ]]; then
				rm ./P1_locus"$i".txt ;
			fi

			## echo -e "$(echo locus $(calc $i -1))\n$(cat $FILE)" > $FILE
			echo "$(echo locus $(calc $i -1))\n$(cat $FILE)" > "$FILE" ;
		done
	)

echo "INFO      | $(date) |          Splitting P2 group SNPs out to separate files... "
	(
		for (( i=1; i<=$MY_N_P2_COL; i++ )); do
			cut -f"$i" $MY_P2_FILE > P2_locus"$i".txt
			FILE=P2_locus"$i".txt
			FILE_SIZE="$(wc -c P2_locus$i.txt | sed 's/\.\///g; s/P2.*//g')"
			FILE_NLINES="$(wc -l P2_locus$i.txt | sed 's/\.\///g; s/P2.*//g')"
			if [[ "$FILE_SIZE" -eq "$FILE_NLINES" ]]; then
				rm ./P2_locus"$i".txt ;
			fi

			## echo -e "$(echo locus $(calc $i -1))\n$(cat $FILE)" > $FILE
			echo "$(echo locus $(calc $i -1))\n$(cat $FILE)" > "$FILE"
		done
	)

echo "INFO      | $(date) |          Splitting admixed group SNPs out to separate files... "
	(
		for (( i=1; i<=$MY_N_ADMIX_COL; i++ )); do
			cut -f"$i" $MY_ADMIXED_FILE > admixed_locus"$i".txt
			FILE=admixed_locus"$i".txt
			FILE_SIZE="$(wc -c admixed_locus$i.txt | sed 's/\.\///g; s/admixed.*//g')"
			FILE_NLINES="$(wc -l admixed_locus$i.txt | sed 's/\.\///g; s/admixed.*//g')"
			if [[ "$FILE_SIZE" -eq "$FILE_NLINES" ]]; then
				rm ./admixed_locus"$i".txt ;
			fi

			## echo -e "$(echo locus $(calc $i -1))\n$(cat $FILE)" > $FILE
			echo "$(echo locus $(calc $i -1))\n$(cat $FILE)" > "$FILE" ;
		done
	)

	##--Organize all files for each pop into a single folder
	mkdir P1_SNPs P2_SNPs admixed_SNPs ;
	mv ./P1_locus*.txt ./P1_SNPs/ ;
	mv ./P2_locus*.txt ./P2_SNPs/ ;
	mv ./admixed_locus*.txt ./admixed_SNPs/ ;


echo "INFO      | $(date) | STEP #5: LOOP THROUGH SNP FILES AND RECODE PRESENT AND MISSING SNP DATA TO MATCH BGC FORMAT. "
#  4. Recode present and missing SNP data. First, change NA's to -9 for each allele: change
#     ``^NA`` with ```\-9\ \-9``. Also recode the SNP data into 0 2, 2 0, 1 1 format.
	(
		for i in ./P1_SNPs/P1_locus*.txt; do
			FILENAME=$(basename "$i"); FILENAME_MINUS_EXT=${FILENAME%.*}
			echo "$FILENAME_MINUS_EXT"
			perl -i -pe 's/^NA/\-9\ \-9/g' "$i" ;
			perl -i -pe 's/^1\:2/1\ 1/g' "$i" ;
			perl -i -pe 's/^1\:1/0\ 2/g' "$i" ;
			perl -i -pe 's/^2\:2/2\ 0/g' "$i" ;
		done
	)
	
	(
		for j in ./P2_SNPs/P2_locus*.txt; do
			FILENAME=$(basename "$j"); FILENAME_MINUS_EXT=${FILENAME%.*}
			echo "$FILENAME_MINUS_EXT"
			perl -i -pe 's/^NA/\-9\ \-9/g' "$j" ;
			perl -i -pe 's/^1\:2/1\ 1/g' "$j" ;
			perl -i -pe 's/^1\:1/0\ 2/g' "$j" ;
			perl -i -pe 's/^2\:2/2\ 0/g' "$j" ;
		done
	)

	(
		for k in ./admixed_SNPs/admixed_locus*.txt; do
			FILENAME=$(basename "$k"); FILENAME_MINUS_EXT=${FILENAME%.*}
			echo "$FILENAME_MINUS_EXT"
			perl -i -pe 's/^NA/\-9\ \-9/g' "$k" ;
			perl -i -pe 's/^1\:2/1\ 1/g' "$k" ;
			perl -i -pe 's/^1\:1/0\ 2/g' "$k" ;
			perl -i -pe 's/^2\:2/2\ 0/g' "$k" ;
		done
	)
	

echo "INFO      | $(date) | STEP #6: PREPARE FINAL P1 AND P2 bgc INPUT FILES. "
	NUM_P1_FILES="$(ls ./P1_SNPs/* | wc -l)";
	NUM_P2_FILES="$(ls ./P2_SNPs/* | wc -l)";
	
	for (( i=1; i<=$NUM_P1_FILES; i++ )); do cat ./P1_SNPs/P1_locus"$i".txt >> ./p0in.txt; done	## This is P1.
	for (( i=1; i<=$NUM_P1_FILES; i++ )); do cat ./P2_SNPs/P2_locus"$i".txt >> ./p1in.txt; done	## This is P2.
	##--Just using $NUM_P1_FILES twice above (for P2 as well) for convenience, since these numbers
	##--should be equal to one another. You could use $NUM_P2_FILES on the second line; however, a
	##--better (more conservative) way would be to check whether these two values were equal, and if
	##--they differed, use only the smaller number. That way, if there are any additional files
	##--created, say maybe 1 or 2 extra loci, at the end, then those would not be included anyway
	##--because you were only looping through the smaller number of files. The code above essentially
	##--assumes that any such errors only affect P2 files.


echo "INFO      | $(date) | STEP #7: PREPARE FINAL ADMIXED bgc INPUT FILE. "
##--Make final admixedIn.txt file by cat'ing all admixed locus SNP files in the "admixed_SNPs"
##--dir to a single file, making sure to use a for loop going in order from 0 to n SNPs,
##--where n is the same number of loci in the P1 and P2 files.
	(
		MY_N_PLUS_ONE="$(calc $MY_N_ADMIX_COL + 1)"
		for (( i=1; i<=$MY_N_PLUS_ONE; i++ )); do
			FILE=./admixed_SNPs/admixed_locus"$i".txt
			cat $FILE >> ./admixedIn.txt ;
		done
	)

	perl -i -pe 's/(locus\ [0-9]*$)/$1\npop\ 0/g' ./admixedIn.txt ;


echo "INFO      | $(date) | STEP #8: CHECK FOR LOCI WITH NO DATA AND REMOVE CORRESPONDING LINES (IF ANY). "
##--Preceding code could potentially cause some lines like "locus X\npop\ 0\n^$", with the
##--locus name followed by pop, but no SNP data on the second line below the locus number. We 
##--therefore need to search for this pattern and remove the corresponding lines if/where
##--found. Finding and counting the 

	BLNKLINES_LOCUS_END="$(grep -n $'^$' ./admixedIn.txt-e | sed 's/\.\///g; s/\://g')";
	if [[ "$BLNKLINES_LOCUS_END" -eq "1" ]]; then
		BLNKLINES_LOCUS_START="$(calc $BLNKLINES_LOCUS_END - 2)";
		sed -i '' "$BLNKLINES_LOCUS_START","$BLNKLINES_LOCUS_END"d ./admixedIn.txt ;
	elif [[ "$BLNKLINES_LOCUS_END" -gt "1" ]]; then
		echo "WARNING!  | $(date) |          Multiple blank lines in the admixed input file. Check and remove the following "
		echo "WARNING!  | $(date) |          blank lines, as needed: "
		echo "WARNING!  | $(date) |          - $BLNKLINES_LOCUS_END. "
	fi


echo "INFO      | $(date) | STEP #9: CHANGE MISSING DATA LINES CODED AS MINUS 9s ('-9 -9') TO ZEROS ('0 0'). "
##--Note: Could also fix this by going back up and replacing NAs with 0 0 under STEP #5 ABOVE, but
##--the following step adds an insignificant amount time to the analysis, so keep for now.
	MY_INPUT_TXT_FILES="$(ls ./p0in.txt ./p1in.txt ./admixedIn.txt)";
	(
		for l in $MY_INPUT_TXT_FILES; do echo "$l"; perl -i -pe 's/^\-9\ \-9/0\ 0/g' "$l"; done
	)
##--Note: final file names are ./p0in.txt ./p1in.txt ./admixedIn.txt. These file names are assumed in bgcRunner and other bgc_tools scripts.


echo " Finished preparing P1, P2, and admixed input files for bgc analysis using the bgcPrepper utility in bgc_tools. "
echo " Bye."
#
#
#
######################################### END ############################################

exit 0
