# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    version=6.0.5
    CONTAINER_IMAGE="index.docker.io/wjallen/fsl:${version}"
fi
. lib/container_exec.sh

# silence xalt errors
module unload xalt


COMMAND="melodic"
INPUTS=" -i ${4dimage} "
OPTS=""

MASK_FILE="${coord_space}${mask_size}"
if [ -n "${MASK_FILE}" ];
then
  OPTS="${OPTS} -m masks/${MASK_FILE} "
else
  echo "must specify mask file"
  exit 1
fi


if [ -n "${dim_red}" ];
then
  OPTS="${OPTS} -d ${dim_red} "
else
  OPTS="${OPTS} -d 20 "
fi


OPTS="${OPTS} -a concat --vn --Oall --report "


echo "================================================================"
echo "COMMAND = container_exec ${CONTAINER_IMAGE} ${COMMAND} ${INPUTS} ${OPTS}"
echo "================================================================"

container_exec ${CONTAINER_IMAGE} ${COMMAND} ${INPUTS} ${OPTS}
