# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    version=$(cat ./_util/VERSION)
    CONTAINER_IMAGE="index.docker.io/library/ubuntu:bionic"
fi
. lib/container_exec.sh


COMMAND="melodic"

INPUTS=" -i ${4dimage} "


OPTS=""

if [ -n "${mask_file}" ];
then
  OPTS="${OPTS} -m masks/${mask_file} "

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

echo "container_exec ${CONTAINER_IMAGE} ${COMMAND} ${INPUTS} ${OPTS}"
container_exec ${CONTAINER_IMAGE} $COMMAND $INPUTS $OPTS
