!/bin/bash -l
#SBATCH -J Combi
#SBATCH --cpus-per-task=8
#SBATCH --mem=32GB
#SBATCH -N 1
#SBATCH --account=AG-Maier
#SBATCH --mail-type=END
#SBATCH --mail-user aleu1@uni-koeln.de  #!
#SBATCH --time=2:00:00
#SBATCH --array=1-10 #!

#Define input and output paths (non-existing directories have to be created before executing this script)
myDataRaw="/scratch/aleu1/BC/Raw/evolExp"
myDataTrim="/scratch/aleu1/BC/Trim"           # where to find the trimmed sequencing reads
myDictPath="/home/aleu1/scripts/BC_Ref" # where to find the dictionary #!
myDataPath="/scratch/aleu1/BC/out"	 # where to save the results #!
myRScriptPath="/home/aleu1/scripts" #

#Define folders where software is installed

samFold="/home/aleu1/software/samtools-1.16.1" #!
bcfFold="/home/aleu1/software/bcftools-1.12" #!
bedFold="/home/aleu1/software/bedtools2/bin" #!
minimapFold="/home/aleu1/software/minimap2-master" #!
PEARFold="/home/aleu1/software/PEAR-master/src" #!
ShepherdFold="/home/aleu1/scripts/Shepherd-main"  #!
#Define variables
i=$SLURM_ARRAY_TASK_ID
dict="Reference_barcode" #!#

ID=$(ls -1 $myDataRaw | grep "R1_001.fastq" | sed -n ''$i'p' | cut -d_ -f1,2) #!
#ID=$(ls -1 $myDataRaw | grep "_R1.fastq" | sed -n ''$i'p' | cut -d_ -f1) #!



IDout=$ID #!


################################## no futher input necessary #######################
Mapping the reads on the reference dictionary

cd $PEARFold
./pear -f $myDataRaw/$ID"_R1_001.fastq" -r $myDataRaw/$ID"_R2_001.fastq" -o $myDataTrim/$ID"_merge"


cd $minimapFold
./minimap2 -a $myDictPath/$dict".fasta" $myDataTrim/$ID"_merge.assembled.fastq" > $myDataPath/$IDout".sam"

#Sort_Script.sh - sorting the mapped reads for faster following steps
cd $samFold
./samtools sort $myDataPath/$IDout".sam" --threads 8 --reference $myDictPath/$dict".fasta" -o $myDataPath/$IDout"_sort.bam"
./samtools index -b $myDataPath/$IDout"_sort.bam" > $myDataPath/$IDout"_sort.bam.bai"
module load R/4.1.3_system

export R_LIBS_USER=$HOME/R/4.1.3

Rscript $myRScriptPath/"extract_barcodes_2.R" $1$myDataPath/$ID

cd $myDataPath

cut -d, -f2,3 $ID"_barcode.txt" | sed -e 's/,/ /g'| sed -e '1d' > $ID"_barcode_cut.txt"

cd $ShepherdFold

module load python/3.7.10_jupyter

python3 shepherd_t0.py -f $myDataPath/$ID"_barcode_cut.txt" -l 25 -e 0.005


exit 0

