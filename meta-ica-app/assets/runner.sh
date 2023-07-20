# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    CONTAINER_IMAGE="wjallen/meta-ica:1.0.0"
fi

SING_IMG=$( basename ${CONTAINER_IMAGE} | tr ':' '_' )
SING_IMG="${SING_IMG}.sif"


# Silence xalt errors
module unload xalt

# set up temp dirs
TEMPDIR1="/tmp/tempdir1"
TEMPDIR2="/tmp/tempdir2"
TEMPDIR3="/tmp/tempdir3"
OUTPUT="/tmp/output"
#TEMPDIR1="tempdir1"
#TEMPDIR2="tempdir2"
#TEMPDIR3="tempdir3"
#OUTPUT="output"
mkdir ${TEMPDIR1}
mkdir ${TEMPDIR2}
mkdir ${TEMPDIR3}
mkdir ${OUTPUT}


# Step 0: Gather input
# input file name
if [ -n "${foci_text}" ];
then
    INPUT="${foci_text}"
else
    INPUT="vbm_mni_exp.txt"
fi

# coord space can be Tal_wb or MNI152_wb
if [[ "${coord_space}" == "Tal_wb" ]];
then
    COORD_SPACE="${coord_space}"
    FORMAT="-tal"
elif [[ "${coord_space}" == "MNI152_wb" ]];
then
    COORD_SPACE="${coord_space}"
    FORMAT="-mni"
fi

MASK="${coord_space}${mask_size}"

# dimensionality reduction
if [ -n "${dim_red}" ];
then
    DIM_RED="${dim_red}"
else
    DIM_RED="20"
fi

# do this on /tmp
JOB_DIR=`pwd`
cp masks/${MASK} /tmp
cp ${INPUT} /tmp
cd /tmp

# Log commands, timing, run job
echo "================================================================"
echo -n "Pulling container, "
date
echo "CONTAINER = singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}"
echo "================================================================"
singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}


# Step 1: Filter and parse input
BINDPATH=" --bind /opt/intel:/opt/intel "
CMD1=" /scratch/tacc/apps/matlab/2022b/bin/matlab "
OPT1=" -nodesktop -nodisplay -nosplash "
MATLAB_FUNC=" make_per_experiment_TXTfiles_for_meta_ICA ${INPUT} ${PWD} ${filtering} "
echo "================================================================"
echo -n "Starting step 1: Filtering and parsing input, "
date
echo "COMMAND1 = singularity exec ${BINDPATH} ${SING_IMG} ${CMD1} ${OPT1} -r ' ${MATLAB_FUNC} ' "
echo "================================================================"
singularity exec ${SING_IMG} cp -r /app/make_per_experiment_TXTfiles_for_meta_ICA.m .
singularity exec ${BINDPATH} ${SING_IMG} ${CMD1} ${OPT1} -r " ${MATLAB_FUNC} "
mv per-experiment*/* ${TEMPDIR1}
rmdir per-experiment*
rm expFiltered*txt

# Step 1: Filter and parse input
#dos2unix ${foci_text}
#awk -v RS= '{print > ("tempdir1/data_" NR ".txt")}' ${INPUT}


# Step 2: Get Activation Maps
# will generate one nifti image per file
CMD2="java -cp /app/GingerALE.jar org.brainmap.meta.getActivationMap "
OPT2="-expanded -gzip ${FORMAT} -mask=$MASK "
echo "================================================================"
echo -n "Starting step 2: Getting activation maps with GingerALE, "
date
echo "COMMAND2 = singularity exec ${SING_IMG} ${CMD2} ${OPT2} <each file>"
echo "================================================================"
N=40 # N simultaneous processes
for FILE in ${TEMPDIR1}/*
do
    ((i=i%$N)); ((i++==0)) && wait
    singularity --quiet exec ${SING_IMG} ${CMD2} ${OPT2} $FILE \
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
echo "COMMAND3.1 = singularity exec ${SING_IMG} ${CMD31} <each file> ${OPT31}"
echo "================================================================"
N=40 # N simultaneous processes
for FILE in ${TEMPDIR2}/*.nii.gz
do
    ((i=i%$N)); ((i++==0)) && wait
    THIS_VAL=` singularity --quiet exec ${SING_IMG} ${CMD31} $FILE ${OPT31} ` \
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
echo "COMMAND3.2 = singularity exec ${SING_IMG} ${CMD32} <each file> ${OPT32a} <each out> ${OPT32b}"
echo "================================================================"
N=40 # N simultaneous processes
for FILE in ${TEMPDIR2}/*.nii.gz
do
    ((i=i%$N)); ((i++==0)) && wait
    FILE_BN=$( basename $FILE ) \
    && singularity --quiet exec ${SING_IMG} ${CMD32} $FILE ${OPT32a} ${TEMPDIR3}/$FILE_BN ${OPT32b} &
done
sleep 30


# Step 4: Merge
# merge all images into one final image
CMD4="fslmerge"
OPT4="-t ${OUTPUT}/mod_4d.nii.gz ${TEMPDIR3}/*.nii.gz"
echo "================================================================"
echo -n "Starting step 4: Merge, "
date
echo "COMMAND4 = singularity exec ${SING_IMG} ${CMD4} ${OPT4}"
echo "================================================================"
export LC_ALL=C
for FILE in ${TEMPDIR3}/*.nii.gz
do
    echo $(basename $FILE) >> ${OUTPUT}/mod_4d.txt;
done
singularity --quiet exec ${SING_IMG} ${CMD4} ${OPT4}


# Step 5: Do ICA with Melodic
CMD5="melodic"
OPT5="-i ${OUTPUT}/mod_4d.nii.gz -d ${DIM_RED} -m ${MASK} --vn --Oall --report"
echo "================================================================"
echo -n "Starting step 5: ICA with Melodic, "
date
echo "COMMAND5 = singularity exec ${SING_IMG} ${CMD5} ${OPT5}"
echo "================================================================"
singularity --quiet exec ${SING_IMG} ${CMD5} ${OPT5}


# Clean up
rm -rf ${TEMPDIR1} ${TEMPDIR2} ${TEMPDIR3}
rm ${SING_IMG}
rm make_per_experiment_TXTfiles_for_meta_ICA.m
rm -rf masks/

echo -n "Done: "
date
