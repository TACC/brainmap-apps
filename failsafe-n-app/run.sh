#!/bin/bash

p=$1
clust=$2
perm=$3
coord_space=$4
mask_size=$5
foci_text=$(find * -type f | grep -v 'tapisjob')

# ALE Testing and Significance
COMMAND1=" java -Xmx16G -Xms16G -cp /app/src/GingerALE.jar org.brainmap.meta.getALE2 "
PARAMS1=" "

#if [ -n "${foci_text}" ];
#then
#	PARAMS1="${PARAMS1} ${foci_text} "
#else
#	echo "Error: foci_text is undefined"
#	exit
#fi

# Get p value
if [ -n "${p}" ];
then
	PARAMS1="${PARAMS1} -p=${p} "
else
	PARAMS1="${PARAMS1} -p=0.01 "
fi

# Get clust
if [ -n "${clust}" ];
then
	PARAMS1="${PARAMS1} -clust=${clust} "
else
	PARAMS1="${PARAMS1} -clust=0.05 "
fi

# Get number of permutations
if [ -n "${perm}" ];
then
	PARAMS1="${PARAMS1} -perm=${perm} "
else
	PARAMS1="${PARAMS1} -perm=5000 "
fi

# Add Mask File
MASK_FILE="${coord_space}${mask_size}"

# can be MNI152_wb.nii.gz, MNI152_wb_dil.nii.gz, Tal_wb.nii.gz, Tal_wb_dil.nii.gz
if [ -n "${MASK_FILE}" ];
then
	PARAMS1="${PARAMS1} -mask=/app/src/masks/${MASK_FILE} "
else
	PARAMS1="${PARAMS1} -mask=/app/src/masks/Tal_wb_dil.nii.gz "
fi

# Add -nonAdd flag
PARAMS1="${PARAMS1} -nonAdd "

# Add a command to get peaks
COMMAND2=" java -cp /app/src/GingerALE.jar org.brainmap.meta.getClustersStats "
FILE_PREFIX=`basename ${foci_text} .txt`
PARAMS2=" ${FILE_PREFIX}_*_C*_ALE.nii ${FILE_PREFIX}_*_C*_clust.nii "

if [ ${coord_space} == "Tal_wb" ];
then
	PARAMS2="${PARAMS2} -tal "
	FORMAT=" -tal "
else
	PARAMS2="${PARAMS2} -mni "
        FORMAT=" -mni "
fi

# Log commands, timing, run job
echo -n "starting: "
date

echo "================================================================"
echo "COMMAND1 = ${COMMAND1} ${foci_text} ${PARAMS1}"
echo "================================================================"
numactl -C 0-7 ${COMMAND1} ${foci_text} ${PARAMS1}

echo "================================================================"
echo "COMMAND2 = ${COMMAND2} ${PARAMS2} "
echo "================================================================"
numactl -C 0-7 ${COMMAND2} ${PARAMS2}


original_peaks_file=$(find * -type f | grep 'peaks.tsv')

# After running first iteration of ALE, Feed original foci_text into FSN script
# to generate null studies
echo "================================================================"
echo "COMMAND3 = python3 /app/src/FSN.py generate ${foci_text} "
echo "================================================================"
python3 /app/src/FSN/FSN.py generate ${foci_text}



# Run COMMAND1 one more time for each of the NULL studies
echo "================================================================"
echo "Running getALE2 on each file modified with null studies"
echo "COMMAND1 = ${COMMAND1} <each file> ${PARAMS1}"
echo "================================================================"
N=10 # N simultaneous tasks
C=8  # cores per task
for FILE in ./*null*txt
do
    ((i=i%$N)); ((i++==0)) && wait
    SC=$(( (i-1)*${C} )) && EC=$(( (i*${C})-1 )) \
    && numactl -C ${SC}-${EC} ${COMMAND1} ${FILE} ${PARAMS1} &
done
sleep 30



# Run COMMAND2 one more time for each of the NULL studies
echo "================================================================"
echo "Running getClustersStats on each output"
echo "COMMAND2 = ${COMMAND2} <each output> ${FORMAT}"
echo "================================================================"
N=10 # N simultaneous tasks
C=8  # cores per task
for FILE in ./*null*txt
do
    ((i=i%$N)); ((i++==0)) && wait
    SC=$(( (i-1)*${C} )) && EC=$(( (i*${C})-1 )) \
    && FILE_PREFIX=`basename ${FILE} .txt` \
    && numactl -C ${SC}-${EC} ${COMMAND2} ${FILE_PREFIX}_*_C*_ALE.nii ${FILE_PREFIX}_*_C*_clust.nii ${FORMAT} &
done
sleep 30



# After running all iterations of ALE, Feed original peaks file into FSN script
# to compare clusters
echo "================================================================"
echo "COMMAND3 = python3 /app/src/FSN.py compare ./${original_peaks_file} "
echo "================================================================"
python3 /app/src/FSN/FSN.py compare ./${original_peaks_file}


# Clean up outputs we don't need
mkdir null-study-files/
mv *_null* null-study-files/
tar -cvzf null-study-files.tar.gz null-study-files/
rm -rf null-study-files/



echo -n "ending: "
date

