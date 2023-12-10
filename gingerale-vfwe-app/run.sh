#!/bin/bash

min_vol=$1
fwe=$2
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

# Get min vol
if [ -n "${min_vol}" ];
then
	PARAMS="${PARAMS} -minVol=${min_vol} "
else
	PARAMS="${PARAMS} -minVol=9 "
fi

# Get fwe
if [ -n "${fwe}" ];
then
	PARAMS="${PARAMS} -fwe=${fwe} "
else
	PARAMS="${PARAMS} -fwe=0.05 "
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
PARAMS2=" ${FILE_PREFIX}_*FWE*_ALE.nii ${FILE_PREFIX}_*FWE*_clust.nii "

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

