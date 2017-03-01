# renseq
Renseq Pacbio pipeline

![Docker infoimage badge](https://img.shields.io/badge/ImageInfo-_5.584_GB/_25_Layers_-blue.svg?style=flat-square)

Apologies for the size of this image, but it installs the entire PACBio SMRT-Analysis suite which is quite big. And apparently, to run the CLI `smrtpipe.py`, [the whole suite *must* be installed](https://github.com/PacificBiosciences/SMRT-Analysis/issues/256), including a mysqldb and a full web stack for a web GUI that is never used. Anyway, most of the bulk seem to be folders mysteriously named "parameters" with a date. Gigs worth of parameters, why not?

## Usage
put your files in a folder that will be mounted in the image as a volume e.g. `data`. Then:

`docker run -ti -v data:/home/admin/data cyverseuk/renseq /home/admin/data/adapter.fasta /home/admin/data/file1.h5 /home/admin/data/file2.h5 etc...`
