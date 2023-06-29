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
OUTPUT="individual-files"
mkdir ${OUTPUT}

# Step 0: Gather input
# input file name
if [ -n "${foci_text}" ];
then
    INPUT="${foci_text}"
else
    INPUT="vbm_mni_exp.txt"
fi

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
singularity exec ${SING_IMG} cp -r /app/README.txt .
singularity exec ${BINDPATH} ${SING_IMG} ${CMD1} ${OPT1} -r " ${MATLAB_FUNC} "

# Clean up
mv per-experiment*/* ${OUTPUT}
rmdir per-experiment*
#rm expFiltered*txt
tar -czf ${OUTPUT}.tar.gz ${OUTPUT}
rm -rf ${OUTPUT}
rm ${SING_IMG}
rm make_per_experiment_TXTfiles_for_meta_ICA.m

echo -n "Done: "
date
