#!/bin/bash

coord_space=$1
mask_size=$2
dim_red=$3
filtering=$4
foci_text=$(find * -type f | grep -v 'tapisjob')

# Set up temp dirs
TEMPDIR1="/tmp/tempdir1"
TEMPDIR2="/tmp/tempdir2"
TEMPDIR3="/tmp/tempdir3"
OUTPUT="/tmp/output"
mkdir ${TEMPDIR1}
mkdir ${TEMPDIR2}
mkdir ${TEMPDIR3}
mkdir ${OUTPUT}

# Check foci text
if [ -n "${foci_text}" ];
then
    INPUT="${foci_text}"
else
	echo "Error: foci_text is undefined"
	exit
fi

# coord_space can be Tal_wb or MNI152_wb
if [ "${coord_space}" == "Tal_wb" ];
then
    COORD_SPACE="${coord_space}"
    FORMAT="-tal"
elif [ "${coord_space}" == "MNI152_wb" ];
then
    COORD_SPACE="${coord_space}"
    FORMAT="-mni"
else
	echo "Error: coord_space=${coord_space} is invalid"
	exit
fi

# Add Mask File
MASK_FILE="${coord_space}${mask_size}"

# Get dimensionality reduction
if [ -n "${dim_red}" ];
then
    DIM_RED="${dim_red}"
else
    DIM_RED="20"
fi

# Get filtering
if [ -n "${filtering}" ];
then
    FILTER="${filtering}"
else
    FILTER="0"
fi

# do this on /tmp
cd /tmp

# Step 1: Filter and parse input
CMD1=" /scratch/tacc/apps/matlab/2022b/bin/matlab "
OPT1=" -nodesktop -nodisplay -nosplash "
MATLAB_FUNC=" make_per_experiment_TXTfiles_for_meta_ICA ${_tapisExecSystemExecDir}/${INPUT} ${PWD} ${FILTER} "
echo "================================================================"
echo -n "Starting step 1: Filtering and parsing input, "
date
echo "COMMAND1 = ${CMD1} ${OPT1} -r ' ${MATLAB_FUNC} ' "
echo "================================================================"
cp /app/src/make_per_experiment_TXTfiles_for_meta_ICA.m .
${CMD1} ${OPT1} -r " ${MATLAB_FUNC} "
mv per-experiment*/* ${TEMPDIR1}
rmdir per-experiment*


# Step 2: Get Activation Maps
# will generate one nifti image per file
CMD2="java -cp /app/src/GingerALE.jar org.brainmap.meta.getActivationMap "
OPT2="-expanded -gzip ${FORMAT} -mask=/app/src/masks/${MASK_FILE} "
echo "================================================================"
echo -n "Starting step 2: Getting activation maps with GingerALE, "
date
echo "COMMAND2 = ${CMD2} ${OPT2} <each file>"
echo "================================================================"
N=40 # N simultaneous processes
for FILE in ${TEMPDIR1}/*
do
    ((i=i%$N)); ((i++==0)) && wait
    ${CMD2} ${OPT2} $FILE \
    && NEW_FILE=$( basename $FILE .txt ) \
    && mv ${TEMPDIR1}/${NEW_FILE}_ALE.nii.gz ${TEMPDIR2}/ &
done
sleep 30


# Step 3: Scale Images
# will generate one scaled nifti image per file
CMD31="fslstats" 
OPT31="-P 100"
IMAGE_TYPE="short"
SCALED_MAX="32000"
MAX_VAL=0
echo "================================================================"
echo -n "Starting step 3.1: Find scaling factor, "
date
echo "COMMAND3.1 = ${CMD31} <each file> ${OPT31}"
echo "================================================================"
N=40 # N simultaneous processes
for FILE in ${TEMPDIR2}/*.nii.gz
do
    ((i=i%$N)); ((i++==0)) && wait
    THIS_VAL=` ${CMD31} $FILE ${OPT31} ` \
    && echo ${THIS_VAL} >> list_of_vals.txt &
done
sleep 30

for VALUE in ` cat list_of_vals.txt `
do
    if (( $(echo "$VALUE > $MAX_VAL" | bc -l) )); then
        MAX_VAL=$VALUE
    fi
done
SCALING=` echo "0 k $SCALED_MAX $MAX_VAL / p" | dc - `
echo "scaleImageDir $TEMPDIR2 max $MAX_VAL * $SCALING ~= $SCALED_MAX $IMAGE_TYPE"
rm list_of_vals.txt


CMD32="fslmaths" 
OPT32a="-mul $SCALING"
OPT32b="-odt $IMAGE_TYPE"
echo "================================================================"
echo -n "Starting step 3.2: Scale images, "
date
echo "COMMAND3.2 = ${CMD32} <each file> ${OPT32a} <each out> ${OPT32b}"
echo "================================================================"
N=40 # N simultaneous processes
for FILE in ${TEMPDIR2}/*.nii.gz
do
    ((i=i%$N)); ((i++==0)) && wait
    FILE_BN=$( basename $FILE ) \
    && ${CMD32} $FILE ${OPT32a} ${TEMPDIR3}/$FILE_BN ${OPT32b} &
done
sleep 30


# Step 4: Merge
# merge all images into one final image
CMD4="fslmerge"
OPT4="-t ${OUTPUT}/mod_4d.nii.gz ${TEMPDIR3}/*.nii.gz"
echo "================================================================"
echo -n "Starting step 4: Merge, "
date
echo "COMMAND4 = ${CMD4} ${OPT4}"
echo "================================================================"
export LC_ALL=C
for FILE in ${TEMPDIR3}/*.nii.gz
do
    echo $(basename $FILE) >> ${OUTPUT}/mod_4d.txt;
done
${CMD4} ${OPT4}


# Step 5: Do ICA with Melodic
CMD5="melodic"
OPT5="-i ${OUTPUT}/mod_4d.nii.gz -d ${DIM_RED} -m /app/src/masks/${MASK_FILE} --vn --Oall --report"
echo "================================================================"
echo -n "Starting step 5: ICA with Melodic, "
date
echo "COMMAND5 = ${CMD5} ${OPT5}"
echo "================================================================"
${CMD5} ${OPT5}


# Clean up
mv ${OUTPUT} ${_tapisExecSystemExecDir}
rm -rf ${TEMPDIR1} ${TEMPDIR2} ${TEMPDIR3}
rm make_per_experiment_TXTfiles_for_meta_ICA.m

echo -n "Done: "
date
