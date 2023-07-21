# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    CONTAINER_IMAGE="wjallen/cbptools:1.1.6"
fi


#COMMAND="melodic"
COMMAND1="cbptools create"
COMMAND2="snakemake"

INPUTS=" --config ${config_yaml} "


OPTS1=""
OPTS2=""

if [ -n "${workdir}" ];
then
  OPTS1="${OPTS1} --workdir ${workdir} "

else
  echo "must specify mask file"
  exit 1

fi


if [ -n "${cores}" ];
then
  OPTS2="${OPTS2} --cores ${cores} "

else
  OPTS2="${OPTS2} --cores all "

fi

OPTS2="${OPTS2} --resources mem_mb=80000 "

module unload xalt
module load tacc-singularity

echo "container_exec ${CONTAINER_IMAGE} ${COMMAND1} ${INPUTS} ${OPTS1}"
container_exec ${CONTAINER_IMAGE} ${COMMAND1} ${INPUTS} ${OPTS1}

cd ${workdir}

echo "container_exec ${CONTAINER_IMAGE} ${COMMAND2} ${OPTS2}"
container_exec ${CONTAINER_IMAGE} ${COMMAND2} ${OPTS2}

