# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    CONTAINER_IMAGE="wjallen/gingerale:3.0.2"
fi

SING_IMG=$( basename ${CONTAINER_IMAGE} | tr ':' '_' )
SING_IMG="${SING_IMG}.sif"
singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}

# silence xalt errors
module unload xalt

#export LC_ALL=C
COMMAND=" java -Xms16G -Xmx16G -cp /app/GingerALE.jar "
PARAMS=" "

# ALE Testing and Significance
if [ 1 ];
then
	COMMAND="${COMMAND} org.brainmap.meta.getALE2 "
fi

if [ -n "${foci_text}" ];
then
	PARAMS="${PARAMS} ${foci_text} "

#elif [ -n "${raw_directory}" ];
#then
#	find ${raw_directory} -type f > filelist.txt
#	PARAMS="${PARAMS} -f filelist.txt "
#
else
	echo "Error: must specify foci text"
	exit
fi

# Add -nonAdd flag
PARAMS="${PARAMS} -nonAdd "

# Add -noPVal flag"
PARAMS="${PARAMS} -noPVal "

# Add Mask File
MASK_FILE="${coord_space}${mask_size}"

if [ -n "${MASK_FILE}" ];
then
	PARAMS="${PARAMS} -mask=masks/${MASK_FILE} "

else
	PARAMS="${PARAMS} -mask=masks/Tal_wb_dil.nii.gz "
fi
# can be MNI152_wb.nii.gz, MNI152_wb_dil.nii.gz, Tal_wb.nii.gz, Tal_wb_dil.nii.gz

# Hack in this command to get peaks
COMMAND2=" java -cp /app/GingerALE.jar org.brainmap.meta.getClustersStats "
FILE_PREFIX=`basename ${foci_text} .txt`
PARAMS2=" ${FILE_PREFIX}_ALE.nii masks/${MASK_FILE} -mni "


# Log commands, timing, run job
echo -n "starting: "
date

echo "================================================================"
echo "CONTAINER = singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}"
echo "================================================================"
echo "COMMAND = singularity exec ${SING_IMG} ${COMMAND} ${PARAMS}"
echo "================================================================"
echo "COMMAND2 = singularity exec ${SING_IMG} ${COMMAND2} ${PARAMS2} "
echo "================================================================"

numactl -C 0 singularity exec ${SING_IMG} ${COMMAND} ${PARAMS}
singularity exec ${SING_IMG} ${COMMAND2} ${PARAMS2}

echo -n "ending: "
date
