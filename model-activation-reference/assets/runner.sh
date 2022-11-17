# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    version=$(cat ./_util/VERSION)
    CONTAINER_IMAGE="index.docker.io/library/ubuntu:bionic"
fi
. lib/container_exec.sh
module unload xalt



SING_IMG='mar_1.0.0.sif'
TEMPDIR1='./tempdir1'
TEMPDIR2='./tempdir2'
TEMPDIR3='./tempdir3'
OUTPUT='./output'
mkdir ${TEMPDIR1}
mkdir ${TEMPDIR2}
#mkdir ${TEMPDIR3} # the script makes this one automatically
mkdir ${OUTPUT}



# Step 0: Gather input (tsv format)
if [ -n "${input_tsv}" ];
then
    INPUT="${input_tsv} "
else
    INPUT="vbm_export_voxels.txt "
fi

# can be -tal or -mni
if [ -n "${format}" ];
then
    FORMAT="${format} "
else
    MASK="-tal "
fi

# can be MNI152_wb.nii.gz, MNI152_wb_dil.nii.gz, Tal_wb.nii.gz, Tal_wb_dil.nii.gz
if [ -n "${mask_file}" ];
then
    MASK="masks/${mask_file} "
else
    MASK="masks/Tal_wb_dil.nii.gz "
fi

# Step 1: Split Experiments
# will generate a bunch of tal text files in the output folder
CMD1=" python /MAR/splitExperiments.py ${INPUT} ${TEMPDIR1} -nosubj"
#container_exec ${CONTAINER_IMAGE} ${CMD1}
singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}
singularity --quiet exec ${SING_IMG} ${CMD1}



# Step 2: Get meta activation map
# will generate one nifti image per file
CP="-cp /app/GingerALE.jar "
MAIN="org.brainmap.meta.getActivationMap "
OPT2="-expanded -gzip "

for FILE in ${TEMPDIR1}/*.txt
do
    #container_exec ${CONTAINER_IMAGE} java $CP $MAIN $OPT2 $FORMAT -mask=${MASK} $FILE
    singularity --quiet exec ${SING_IMG} java $CP $MAIN $OPT2 $FORMAT -mask=${MASK} $FILE
    NEW_FILE=$( basename $FILE .txt )
    mv ${TEMPDIR1}/${NEW_FILE}_ALE.nii.gz ${TEMPDIR2}/
done



# Step 3: Scale Images
# will generate one scaled nifti image per file
CMD3="bash /MAR/scaleImageDir.sh "
OPT3="${TEMPDIR2} ${TEMPDIR3} -float "
#container_exec ${CONTAINER_IMAGE} ${CMD3} ${OPT3}
singularity --quiet exec ${SING_IMG} ${CMD3} ${OPT3}



# Step 4: Merge
# merge all images into one final image
CMD4="fslmerge "
export LC_ALL=C
for IMAGE in ${TEMPDIR3}/*nii.gz
do
    echo $(basename $IMAGE) >> ${OUTPUT}/mar_4d.txt;
done

#container_exec ${CONTAINER_IMAGE} ${CMD4} -t ${OUTPUT}/mar_4d.nii.gz ${TEMPDIR3}/*nii.gz
singularity --quiet exec ${SING_IMG} ${CMD4} -t ${OUTPUT}/mar_4d.nii.gz ${TEMPDIR3}/*nii.gz




# Clean up
rm -rf ${TEMPDIR1} ${TEMPDIR2} ${TEMPDIR3}
