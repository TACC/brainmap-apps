# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    CONTAINER_IMAGE="wjallen/author-topic:1.0.0"
fi

SING_IMG=$( basename ${CONTAINER_IMAGE} | tr ':' '_' )
SING_IMG="${SING_IMG}.sif"
singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}

# Silence xalt errors
module unload xalt

# Grab foci text from user, must be MNI
if [ -n "${foci_text}" ];
then
	ENVIRON=" --env foci_text=${foci_text} "
else
	echo "Error: must specify foci text"
	exit
fi

# Needed for LAPACK and BLAS
BINDPATH=" --bind /opt/intel:/opt/intel "

COMMAND="  /scratch/tacc/apps/matlab/2022b/bin/matlab "
PARAMS=" -nodesktop -nodisplay -nosplash "
PARAMS=" ${PARAMS} < matlab_wrapper.m "


# Log commands, timing, run job
echo -n "starting: "
date

echo "================================================================"
echo "CONTAINER = singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}"
echo "================================================================"
echo "COMMAND = singularity exec ${ENVIRON} ${BINDPATH} ${SING_IMG} ${COMMAND} ${PARAMS}"
echo "================================================================"

singularity exec ${ENVIRON} ${BINDPATH} ${SING_IMG} ${COMMAND} ${PARAMS}

echo -n "ending: "
date

