#!/usr/bin/env python



## Author: Pirita Paajanen 26.11.2015
# This script takes as an input a adapter.fasta file, and a bax.h5 file from PacBio data, 
# calculates the length of the longest adapter sequence, and after that edits the bas.h5 file
# to trim the extra adapter sequences off from the PacBio reads so that when you feed this 
# file onto smrtanalysis software


## The script finds the /PulseData/Regions section in the input hdf5 file and removes the length of the adapter
# and for the area marked by 1 by which consists of the reads, trim it by the length of the adapters at both
# ends.

import sys
import string
import re
import numpy 
import h5py

trim_by=int(sys.argv[1])

bas5=(sys.argv[2]) # the file to be edited


with h5py.File('{}'.format(bas5), 'a') as g:   #Open the bas.h5 file in append mode
    for i in range(g['/PulseData/Regions'].shape[0]):   # iterate over all the rows in the /PulseData/Regions part of the file
        if g['/PulseData/Regions'][i,1]==1:  # Check whether you are in the area that has been identified to be between the bell adapters by the software
            if int(g['/PulseData/Regions'][i,3])-int(g['/PulseData/Regions'][i,2])<500: # Ignore these regions if the length of the read is less than 500 
                continue
            else:
                g['/PulseData/Regions'][i,3]=int(g['/PulseData/Regions'][i,3])-trim_by  # Otherwise, trim the upper end by the length of the longest adapter
                if g['/PulseData/Regions'][i,2]!=0:
                    g['/PulseData/Regions'][i,2]=int(g['/PulseData/Regions'][i,2])+ trim_by # trim the lower end by the length of the longest adapter
