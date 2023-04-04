# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    CONTAINER_IMAGE="wjallen/mar:1.0.0"
fi

SING_IMG=$( basename ${CONTAINER_IMAGE} | tr ':' '_' )
SING_IMG="${SING_IMG}.sif"
singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}

# silence xalt errors
module unload xalt

# set up temp dirs
TEMPDIR1="./tempdir1"
TEMPDIR2="./tempdir2"
TEMPDIR3="./tempdir3"
OUTPUT="./output"
mkdir ${TEMPDIR1}
mkdir ${TEMPDIR2}
mkdir ${TEMPDIR3}
mkdir ${OUTPUT}


# Step 0: Gather input

# input file name
if [ -n "${input_tsv}" ];
then
    INPUT="${input_tsv}"
else
    INPUT="vbm_export_voxels.txt"
fi

# coord space can be -tal or -mni
if [ -n "${coord_space}" ];
then
    FORMAT="${coord_space}"
else
    FORMAT="-tal"
fi

# mask can be MNI152_wb.nii.gz, MNI152_wb_dil.nii.gz, Tal_wb.nii.gz, Tal_wb_dil.nii.gz
if [ -n "${mask_file}" ];
then
    MASK="masks/${mask_file}"
else
    MASK="masks/Tal_wb_dil.nii.gz"
fi

# output can be formatted for macm or cbp
if [ "${output_format}" == "macm" ];
then
    OUTPUT_FORMAT="macm"
    OUTPUT_FLAG="-1d"
    IMAGE_TYPE="char"
elif [ "${output_format}" == "cbp" ];
then
    OUTPUT_FORMAT="cbp"
    OUTPUT_FLAG="-cc"
    IMAGE_TYPE="float"
else
    OUTPUT_FORMAT="macm"
    OUTPUT_FLAG="-1d"
    IMAGE_TYPE="char"
fi


# Log commands, timing, run job
echo "================================================================"
echo "CONTAINER = singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}"
echo "================================================================"


# Step 1: Split Experiments
# will generate a bunch of tal text files in the output folder
CMD1="python /MAR/splitExperiments.py"
OPT1="${INPUT} ${TEMPDIR1} -nosubj"
echo "================================================================"
echo -n "starting step 1: Split experiments, "
date
echo "COMMAND1 = singularity exec ${SING_IMG} ${CMD1} ${OPT1}"
echo "================================================================"
singularity --quiet exec ${SING_IMG} ${CMD1} ${OPT1}


# Step 2: Get meta activation map or foci image
# will generate one nifti image per file
if [ "${output_format}" == "cbp" ];
then
    CMD2="java -cp /app/GingerALE.jar org.brainmap.meta.getActivationMap "
    OPT2="-expanded -gzip $FORMAT -mask=${MASK}"
elif [ "${output_format}" == "macm" ];
then
    CMD2="java -cp /app/GingerALE.jar org.brainmap.meta.getFociImage "
    OPT2="-gzip $FORMAT -mask=${MASK}"
fi
echo "================================================================"
echo -n "starting step 2: Get meta activation maps or foci images, "
date
echo "COMMAND2 = singularity exec ${SING_IMG} ${CMD2} ${OPT2} <each file>"
echo "================================================================"
N=40 # N simultaneous processes
for FILE in ${TEMPDIR1}/*.txt
do
    ((i=i%$N)); ((i++==0)) && wait
    singularity --quiet exec ${SING_IMG} ${CMD2} ${OPT2} $FILE \
    && NEW_FILE=$( basename $FILE .txt ) \
    && mv ${TEMPDIR1}/${NEW_FILE}.nii.gz ${TEMPDIR2}/ &
done
sleep 10


# Step 3: Scale Images
# will generate one scaled nifti image per file
CMD31="fslstats" 
OPT31="-P 100"
echo "================================================================"
echo -n "starting step 3.1: Find scaling factor, "
date
echo "COMMAND3.1 = singularity exec ${SING_IMG} ${CMD31} <each file> ${OPT31}"
echo "================================================================"
if [ "${output_format}" == "cbp" ];
then
    SCALED_MAX="100000"
    MAX_VAL=0
    N=40 # N simultaneous processes
    for FILE in ${TEMPDIR2}/*.nii.gz
    do
        ((i=i%$N)); ((i++==0)) && wait
        THIS_VAL=` singularity --quiet exec ${SING_IMG} ${CMD31} ${FILE} ${OPT31} ` \
        && echo ${THIS_VAL} >> list_of_vals.txt &
    done
    for VALUE in ` cat list_of_vals.txt `
    do
        if (( $(echo "$VALUE > $MAX_VAL" | bc -l) )); then
            MAX_VAL=$VALUE
        fi
    done
    SCALING=` echo "0 k $SCALED_MAX $MAX_VAL / p" | dc - `
    echo "scaleImageDir $TEMPDIR2 max $MAX_VAL * $SCALING ~= $SCALED_MAX $IMAGE_TYPE"
    rm list_of_vals.txt
elif [ "${output_format}" == "macm" ];
then
    echo "not scaling because this is macm"
fi
sleep 10


CMD32="fslmaths" 
OPT32a=""
if [ "${output_format}" == "cbp" ];
then
    OPT32a="-mul $SCALING"
fi
OPT32b="-odt $IMAGE_TYPE"
echo "================================================================"
echo -n "starting step 3.2: Scale images, "
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
sleep 10


# Step 4: Merge
# merge all images into one final image
CMD4="fslmerge"
OPT4="-t ${OUTPUT}/mar_4d.nii.gz ${TEMPDIR3}/*.nii.gz"
echo "================================================================"
echo -n "starting step 4: Merge, "
date
echo "COMMAND4 = singularity exec ${SING_IMG} ${CMD4} ${OPT4}"
echo "================================================================"
export LC_ALL=C
for FILE in ${TEMPDIR3}/*.nii.gz
do
    echo $(basename $FILE) >> ${OUTPUT}/mar_4d.txt;
done
singularity --quiet exec ${SING_IMG} ${CMD4} ${OPT4}


# Step 5: Generate Voxelwise Output
# Will generate a ton of output nifti
# for CBP - currently working but needs to be sped up and files need to be put in more directories
cd ${OUTPUT}
CMD5="python3 /MAR/voxelwise.py"
OPT5="mar_4d.nii.gz ${OUTPUT_FLAG}"
echo "================================================================"
echo -n "starting step 5: Generate voxelwise output for ${OUTPUT_FORMAT}, "
date
echo "COMMAND5 = singularity exec ${SING_IMG} ${CMD5} ${OPT5}"
echo "================================================================"
singularity --quiet exec ../${SING_IMG} ${CMD5} ${OPT5} 
cd ../ 


# For CBP, remove 1D output dir; just keep CC output dir
# Clean up
echo "================================================================"
echo -n "Ending: Packing up output for archive, "
date
echo "================================================================"
mv ${TEMPDIR1} exps_for_macm
tar -czf exps_for_macm.tar.gz exps_for_macm/         # MACM needs this
tar -czf output.tar.gz ${OUTPUT}
find ${OUTPUT} | sort > output_manifest.txt
rm -rf exps_for_macm/ ${TEMPDIR2} ${TEMPDIR3} ${OUTPUT}
rm ${SING_IMG}

echo -n "Done: "
date
