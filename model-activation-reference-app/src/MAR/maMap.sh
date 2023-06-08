#!/bin/bash

# takes directory of foci & reference space (-tal or -mni)
DIR=$1
REF=$2
DATA=$3

# class path and main class
CP="-cp GingerALE.jar"
MAIN="org.brainmap.meta.getActivationMap"

# use expanded mask & compress the output files
OPT="-expanded -gzip"

for FILE in ${DIR}/*.txt
do
	java $CP $MAIN $OPT $REF $FILE
done
