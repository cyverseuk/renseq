#!/bin/bash

# Author: Erik v.d. Bergh
# Runs the RenSeq Pipeline developed in TGAC by Pirita Paajananen

# TODO add the genomesize and readlength parameter

# Thanks to RObert Siemer on StackOverflow for the getopts tutorial:
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

# default num threads is 2
nproc=2
genomesize=7000000

PARSED=`getopt -o t:g: --long genomesize,threads -n "$0" -- "$@"`
eval set -- "$PARSED"

while true; do
  case "$1" in
  -t|--threads)
    echo Picked up threads option, using "$2" threads
    nproc="$2"
    shift 2
    ;;
  -g|--genomesize)
    echo Picked up genomesize option, using "$2" as genomesize
    genomesize="$2"
    shift 2
    ;;
  --)
    shift
    break
    ;;
  esac
done

. $("/opt/smrtanalysis/admin/bin/getsetupfile")

basedir=`readlink -f $0`
echo "basedir is $basedir"
basedir=$(dirname $basedir)
echo "scriptsdir is $basedir"



if [ "$#" -lt 2 ]; then
  echo -e "\nUsage:\trunRenSeq.sh adapter.fasta file1.h5 file2.h5 ...\nOptional: -t [int] to give number of threads. Default number of threads is 2\n"
  exit
fi

ADAPTER=$1

ARGV=("$@")
NUMFILES=${#ARGV[@]}

#echo [`date`] processing $NUMFILES data files

echo [`date`] Creating output directory
mkdir output
echo [`date`] Moving data into output dir
mv $ADAPTER output
ADAPTER=`basename $ADAPTER`

for (( i=1; $i<${NUMFILES}; i++ )) ; do
  raw=${ARGV[$i]}
  mv $raw output
  ARGV[$i]=`basename ${ARGV[$i]}`
done

cd output



echo [`date`] Making directories 1-blasr/raw and 1-blasr/trimmed
mkdir -p 1-blasr/{raw,trimmed}

# This step can be skipped, but is a good check
# that the adapters are correct.
#
#for raw in "$@"; do
#  rawbase=`basename $raw`
#  blasr $raw $ADAPTER -m 1 -bestn 1 -out 1-blasr/raw/$rawbase.m4
#done

echo [`date`] Finding trim length...
trim_by=`python $basedir/3-find_trim_by.py $ADAPTER`
echo [`date`] Using trim length $trim_by

echo [`date`] Trimming adapters from h5 files...
for (( i=1; $i<${NUMFILES}; i++ )) ; do
  raw=${ARGV[$i]}
  echo [`date`] Trimming file $raw...
  python $basedir/4-edit-h5.py $trim_by $raw
done
echo [`date`] Trimmed adapters from files

echo [`date`] Running blasr on trimmed files...
for (( i=1; i<${NUMFILES}; i++ )) ; do
  raw=${ARGV[$i]}
  echo [`date`] Running blasr on $raw
  rawbase=`basename $raw`
  blasr $raw $ADAPTER -nproc $nproc -m 1 -bestn 1 -out 1-blasr/trimmed/$rawbase.m4

done
echo [`date`] Blasr on trimmed files done

# EvdB: Not sure how to get holenumbers for other runs?
#
#for raw in "$@"; do
#  echo [`date`] Dumping number of holes in hole.$rawbase
#  rawbase=`basename $raw`
#  h5dump -y -d HoleNumber $raw | head > hole.$rawbase
#done

echo [`date`] Extracting whitelist...
for raw in 1-blasr/trimmed/*.m4; do
  echo [`date`] Extracting whitelist from $raw
  rawbase=`basename $raw`
  python $basedir/7-whitelist.py $raw 54494 > $rawbase.whitelist
  WHITELIST=$rawbase.whitelist
done

echo [`date`] inserting parameters and generating params.xml
python $basedir/insert_params.py $basedir/param_template.xml whiteList `pwd`/$WHITELIST > params.xml
python $basedir/insert_params.py $basedir/params.xml genomeSize $genomesize > params.xml

echo [`date`] generating input.xml
rm input.fofn 2>/dev/null

for (( i=1; i<${NUMFILES}; i++ )) ; do
  raw=${ARGV[$i]}
  echo `readlink -f $raw` >> input.fofn
done

fofnToSmrtpipeInput.py input.fofn > input.xml

echo [`date`] Running smartpipe...
# TODO make NPROC a parameter for the script
smrtpipe.py -D NPROC=$nproc -D CLUSTER=BASH -D MAX_THREADS=4 --params=params.xml xml:input.xml > smrtpipe.log
