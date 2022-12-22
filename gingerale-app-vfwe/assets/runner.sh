# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    version=$(cat ./_util/VERSION)
    CONTAINER_IMAGE="index.docker.io/wjallen/gingerale:${version}"
fi
. lib/container_exec.sh

# silence xalt errors
module unload xalt



#export LC_ALL=C
COMMAND=" java -Xmx16G -Xms16G -cp /app/GingerALE.jar "
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


if [ -n "${fwe}" ];
then
        PARAMS="${PARAMS} -fwe=${fwe} "
else
        PARAMS="${PARAMS} -few=0.05 "
fi

if [ -n "${perm}" ];
then
        PARAMS="${PARAMS} -perm=${perm} "
else
        PARAMS="${PARAMS} -perm=5000 "
fi


if [ -n "${minVol}" ];
then
	PARAMS="${PARAMS} -minVol=${minVol} "
else
	PARAMS="${PARAMS} -minVol=9 "
fi


# Add Mask File
MASK_FILE="${coord_space}${mask_size}"

if [ -n "${MASK_FILE}" ];
then
        PARAMS="${PARAMS} -mask=masks/${MASK_FILE} "

else
        PARAMS="${PARAMS} -mask=masks/Tal_wb_dil.nii.gz "
fi
# can be MNI152_wb.nii.gz, MNI152_wb_dil.nii.gz, Tal_wb.nii.gz, Tal_wb_dil.nii.gz

# Add -nonAdd flag
PARAMS="${PARAMS} -nonAdd "


echo "================================================================"
echo "COMMAND = container_exec ${CONTAINER_IMAGE} ${COMMAND} ${PARAMS}"
echo "================================================================"

time container_exec ${CONTAINER_IMAGE} ${COMMAND} ${PARAMS}
