# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    version=$(cat ./_util/VERSION)
    CONTAINER_IMAGE="index.docker.io/wallen/gingerale:${version}"
fi
. lib/container_exec.sh



#export LC_ALL=C
COMMAND=" java -cp /app/GingerALE.jar "
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


if [ -n "${p}" ];
then
	PARAMS="${PARAMS} -p=${p} "

else
	PARAMS="${PARAMS} -p=0.01 "
fi

if [ -n "${minVol}" ];
then
	PARAMS="${PARAMS} -minVol=${minVol} "
else
	PARAMS="${PARAMS} -minVol=200 "
fi


echo "================================================================"
echo "COMMAND = container_exec ${CONTAINER_IMAGE} ${COMMAND} ${PARAMS}"
echo "================================================================"

container_exec ${CONTAINER_IMAGE} ${COMMAND} ${PARAMS}


