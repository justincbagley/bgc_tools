#!/bin/bash

#SBATCH --time=72:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=5120M   # memory per CPU core
#SBATCH -J "SWWP_5KSNPs_bgc_168h_run1"   # job name
#SBATCH --mail-user=<EMAIL_ADDRESS_HERE>   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

##--Example code for running bgc with three input files of SNPS from NGS protocol (ddRADseq 
##--experiment with Illumina HiSeq), with ASCII output and no sequencing error model:

bgc -a p0in.txt -b ./p1in.txt -h ./admixedIn.txt -O 1 -x 45000 -n 25000 -p 1 -q 1 -N 0 -m 0 -t 20 -d 1 -s 1 -I 1 -u 0.1

cd "$PBS_O_WORKDIR"

exit 0
