#!/usr/bin/env python

# Pirita Paajanen Nov 2015

# This script creates a whitelist of the reads that will be acceptable

import sys
import string
# NOTE: this script assumes a single movie in the blasr alignment

blacklist_alignment = sys.argv[1]

bax=string.strip(blacklist_alignment)
parts=bax.split('.')
movie=int(parts[1]) # find out which of the three bax.h5 files it is

#print movie
num_holes = int(sys.argv[2]) # the number of holes, assumed to be 54494


blacklist = set()
movie_prefix = None
for line in open(blacklist_alignment):
    if line.startswith('qname'):
        continue

    cols = line.split()
    #print cols
    
    alignment_id_parts = cols[0].split('/')
    #print alignment_id_parts
    if movie_prefix is None:
        movie_prefix = alignment_id_parts[0]

    hole_num = alignment_id_parts[1]
    #print hole_num
    blacklist.add(hole_num)


#print (movie-1)*num_holes+1,movie*num_holes+1

for i in range((movie-1)*num_holes+1,movie*num_holes+1):
    i = str(i)
    if i not in blacklist:
        print '/'.join([movie_prefix, i])