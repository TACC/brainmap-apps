#!/bin/bash
set -e

# takes directory of foci & reference space (-tal or -mni)
DIR=$1
REF=$2
DATA=$3

# class path and main class
CP="-cp ../jars/GingerALE.jar"
MAIN="org.brainmap.meta.getActivationMap"
MYMASK="./masks/Tal_wb_dil.nii.gz"
echo "Just ran MYMASK"

# use expanded mask & compress the output files
OPT="-expanded -gzip"

for FILE in ../db/${DIR}/*.txt
do
	java $CP $MAIN $OPT $REF -mask=$MYMASK $FILE
done
