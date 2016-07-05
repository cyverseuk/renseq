#!/usr/bin/env python

## Author: Pirita Paajanen 19.11.2015
# This script takes as an input a adapter.fasta file and 
# calculates the length of the longest adapter sequence

import sys
import string

adapter=(sys.argv[1])

def join_fasta(fa):
    name, seq = None, []
    for line in fa:
        line = string.strip(line)
        if line[0]==">":
            if name: yield (name, ''.join(seq))
            name, seq = line, []
        else:
            seq.append(line)
    if name: yield (name, ''.join(seq))


k=0
with open('{0}'.format(adapter), 'r') as fa:
    for seq in join_fasta(fa):
        if len(seq[1])>k:
            k=len(seq[1])
            
trim_by=k

print trim_by

            
            

