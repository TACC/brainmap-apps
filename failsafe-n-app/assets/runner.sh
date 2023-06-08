# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    CONTAINER_IMAGE="wjallen/gingerale:3.0.2"
fi

SING_IMG=$( basename ${CONTAINER_IMAGE} | tr ':' '_' )
SING_IMG="${SING_IMG}.sif"

# silence xalt errors
module unload xalt

#export LC_ALL=C
GA_CMD=" java -Xmx16G -Xms16G -cp /app/GingerALE.jar "
GA_OPT=" "

# ALE Testing and Significance
if [ 1 ];
then
	GA_CMD="${GA_CMD} org.brainmap.meta.getALE2 "
fi

if [ -n "${foci_text}" ];
then
	GA_OPT="${GA_OPT} ${foci_text} "
else
	echo "Error: must specify foci text"
	exit
fi

if [ -n "${p}" ];
then
	GA_OPT="${GA_OPT} -p=${p} "
else
	GA_OPT="${GA_OPT} -p=0.01 "
fi

if [ -n "${fwe}" ];
then
	GA_OPT="${GA_OPT} -fwe=${fwe} "
else
	GA_OPT="${GA_OPT} -few=0.05 "
fi

if [ -n "${perm}" ];
then
	GA_OPT="${GA_OPT} -perm=${perm} "
else
	GA_OPT="${GA_OPT} -perm=5000 "
fi

# Add Mask File
MASK_FILE="${coord_space}${mask_size}"

if [ -n "${MASK_FILE}" ];
then
        GA_OPT="${GA_OPT} -mask=masks/${MASK_FILE} "
else
        GA_OPT="${GA_OPT} -mask=masks/Tal_wb_dil.nii.gz "
fi
# can be MNI152_wb.nii.gz, MNI152_wb_dil.nii.gz, Tal_wb.nii.gz, Tal_wb_dil.nii.gz

# Add -nonAdd flag
GA_OPT="${GA_OPT} -nonAdd "



# Log command, timing, run job
echo "================================================================"
echo -n "Pulling container, "
date
echo "CONTAINER = singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}"
echo "================================================================"
singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}



# Step 1: Run Shell.py



# Step 2: Run GingerAle
echo "================================================================"
echo -n "Starting step 3: Running GingerALE to produce MA maps, "
date
echo "COMMAND = singularity exec ${SING_IMG} ${GA_CMD} ${GA_OPT}"
echo "================================================================"
numactl -C 0-7 singularity exec ${SING_IMG} ${GA_CMD} ${GA_OPT}


# Iterate



# Step 6: Clean up
echo "================================================================"
echo -n "Cleaning up, "
date

#rm failsafe-n_1.0.0.sif
#rm -rf masks/


echo -n "Done: "
date
echo "================================================================"

