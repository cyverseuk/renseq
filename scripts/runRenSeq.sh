#!/bin/bash

# Author: Erik v.d. Bergh
# Runs the RenSeq Pipeline developed in TGAC by Pirita Paajananen

. $("/opt/smrtanalysis/admin/bin/getsetupfile")

if [ "$#" -ne 2 ]; then
  echo -e "\nUsage:\trunRenSeq.sh path/to/data adapter.fasta\n"
  exit
fi

DATADIR=$1
ADAPTER=$2

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
trim_by=`python 3-find_trim_by.py $ADAPTER`
echo [`date`] Using trim length $trim_by

echo [`date`] Trimming adapters from h5 files...
for raw in $DATADIR/*; do
  echo [`date`] Trimming file $raw...
  python 4-edit-h5.py $trim_by $raw
done
echo [`date`] Trimmed adapters from files

echo [`date`] Running blasr on trimmed files...
for raw in $DATADIR/*; do
  echo [`date`] Running blasr on $raw
  rawbase=`basename $raw`
  blasr $raw $ADAPTER -m 1 -bestn 1 -out 1-blasr/trimmed/$rawbase.m4
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
  python 7-whitelist.py $raw 54494 > $rawbase.whitelist
  WHITELIST=$rawbase.whitelist
done

echo [`date`] inserting parameters and generating params.xml
python insert_params.py params_v5.xml `pwd`/$WHITELIST > params.xml

echo [`date`] generating input.xml
rm input.fofn

for raw in $DATADIR/*; do
  echo `pwd`/$raw >> input.fofn
done

fofnToSmrtpipeInput.py input.fofn > input.xml

echo [`date`] Running smartpipe...
smrtpipe.py -D NPROC=3 -D CLUSTER=BASH -D MAX_THREADS=4 --params=params.xml xml:input.xml > smrtpipe.log
