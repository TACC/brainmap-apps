#!/bin/bash

coord_space=$1
mask_size=$2
foci_text=$(find * -type f | grep -v 'tapisjob')

# ALE Testing and Significance
COMMAND=" java -Xms16G -Xmx16G -cp /app/src/GingerALE.jar org.brainmap.meta.getALE2 "
PARAMS=" "

if [ -n "${foci_text}" ];
then
	PARAMS="${PARAMS} ${foci_text} "
else
	echo "Error: foci_text is undefined"
	exit
fi

# Add -nonAdd flag
PARAMS="${PARAMS} -nonAdd "

# Add -noPVal flag"
PARAMS="${PARAMS} -noPVal "

# Add Mask File
MASK_FILE="${coord_space}${mask_size}"

# can be MNI152_wb.nii.gz, MNI152_wb_dil.nii.gz, Tal_wb.nii.gz, Tal_wb_dil.nii.gz
if [ -n "${MASK_FILE}" ];
then
	PARAMS="${PARAMS} -mask=/app/src/masks/${MASK_FILE} "
else
	PARAMS="${PARAMS} -mask=/app/src/masks/Tal_wb_dil.nii.gz "
fi

# Add a command to get peaks
COMMAND2=" java -cp /app/src/GingerALE.jar org.brainmap.meta.getClustersStats "
FILE_PREFIX=`basename ${foci_text} .txt`
PARAMS2=" ${FILE_PREFIX}_ALE.nii /app/src/masks/${MASK_FILE} "

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
echo "COMMAND1 = ${COMMAND} ${PARAMS}"
echo "================================================================"
${COMMAND} ${PARAMS}

echo "================================================================"
echo "COMMAND2 = ${COMMAND2} ${PARAMS2}"
echo "================================================================"
${COMMAND2} ${PARAMS2}

echo -n "ending: "
date
