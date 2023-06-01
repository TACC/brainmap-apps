# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    CONTAINER_IMAGE="wjallen/graph-theory:1.0.0"
fi

SING_IMG=$( basename ${CONTAINER_IMAGE} | tr ':' '_' )
SING_IMG="${SING_IMG}.sif"
singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}

# Silence xalt errors
module unload xalt

# Needed for matlab
BINDPATH=" --bind /opt/intel:/opt/intel "

COMMAND=" /scratch/tacc/apps/matlab/2022b/bin/matlab "
PARAMS=" -nodesktop -nodisplay -nosplash "
MATLAB_FUNC="gtm ${PWD}/xGTM_portal/ ${foci_text} ${radius} ${ale} ${filter}"


# Pull some assets out of container, input file needs to be in asset dir
singularity exec ${SING_IMG} cp -r /xGTM_portal .
mv ${foci_text} xGTM_portal/
chmod +rx xGTM_portal/${foci_text}

# Log commands, timing, run job
echo -n "starting: "
date

echo "================================================================"
echo "CONTAINER = singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}"
echo "================================================================"
echo "COMMAND = singularity exec ${BINDPATH} ${SING_IMG} ${COMMAND} ${PARAMS} -r ' ${MATLAB_FUNC} ' "
echo "================================================================"

singularity exec ${BINDPATH} ${SING_IMG} ${COMMAND} ${PARAMS} -r " ${MATLAB_FUNC} "

mkdir output/
mv xGTM_portal/${foci_text} ./
mv xGTM_portal/${foci_text%.*}* ./output/

if [ "${filter}" == "0" ]; then
    tar -czf per-experiment_TXTfiles-noFilter.tar.gz -C xGTM_portal/ per-experiment_TXTfiles-noFilter
    mv per-experiment_TXTfiles-noFilter.tar.gz output/

elif [ "${filter}" == "1" ]; then
    tar -czf per-experiment_TXTfiles-expFilter.tar.gz -C xGTM_portal/ per-experiment_TXTfiles-expFilter
    mv per-experiment_TXTfiles-expFilter.tar.gz output/

elif [ "${filter}" == "2" ]; then
    tar -czf per-experiment_TXTfiles-papFilter.tar.gz -C xGTM_portal/ per-experiment_TXTfiles-papFilter
    mv per-experiment_TXTfiles-papFilter.tar.gz output/

fi

tar -czf MA_Z.tar.gz -C xGTM_portal/ MA_Z/
mv MA_Z.tar.gz output/

rm -rf ${SING_IMG} xGTM_portal/

echo -n "ending: "
date

