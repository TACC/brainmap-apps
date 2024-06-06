#!/bin/bash

p=$1
clust=$2
perm=$3
coord_space=$4
mask_size=$5
foci_text=$(find * -type f | grep -v 'tapisjob')

# ALE Testing and Significance
COMMAND=" java -Xmx16G -Xms16G -cp /app/src/GingerALE.jar org.brainmap.meta.getALE2 "
PARAMS=" "

if [ -n "${foci_text}" ];
then
	PARAMS="${PARAMS} ${foci_text} "
else
	echo "Error: foci_text is undefined"
	exit
fi

# Get p value
if [ -n "${p}" ];
then
	PARAMS="${PARAMS} -p=${p} "
else
	PARAMS="${PARAMS} -p=0.01 "
fi

# Get clust
if [ -n "${clust}" ];
then
	PARAMS="${PARAMS} -clust=${clust} "
else
	PARAMS="${PARAMS} -clust=0.05 "
fi

# Get number of permutations
if [ -n "${perm}" ];
then
	PARAMS="${PARAMS} -perm=${perm} "
else
	PARAMS="${PARAMS} -perm=5000 "
fi

# Add Mask File
MASK_FILE="${coord_space}${mask_size}"

# can be MNI152_wb.nii.gz, MNI152_wb_dil.nii.gz, Tal_wb.nii.gz, Tal_wb_dil.nii.gz
if [ -n "${MASK_FILE}" ];
then
	PARAMS="${PARAMS} -mask=/app/src/masks/${MASK_FILE} "
else
	PARAMS="${PARAMS} -mask=/app/src/masks/Tal_wb_dil.nii.gz "
fi

# Add -nonAdd flag
PARAMS="${PARAMS} -nonAdd "

# Add a command to get peaks
COMMAND2=" java -cp /app/src/GingerALE.jar org.brainmap.meta.getClustersStats "
FILE_PREFIX=`basename ${foci_text} .txt`
PARAMS2=" ${FILE_PREFIX}_*_C*_ALE.nii ${FILE_PREFIX}_*_C*_clust.nii "

if [ ${coord_space} == "Tal_wb" ];
then
	PARAMS2="${PARAMS2} -tal "
else
	PARAMS2="${PARAMS2} -mni "
fi

# Log commands, timing, run job
echo -n "starting: "
date

echo "================================================================"
echo "COMMAND = ${COMMAND} ${PARAMS}"
echo "================================================================"
${COMMAND} ${PARAMS}

echo "================================================================"
echo "COMMAND2 = ${COMMAND2} ${PARAMS2} "
echo "================================================================"
${COMMAND2} ${PARAMS2}

echo -n "ending: "
date

