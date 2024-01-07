#!/bin/bash

radius=$1
ale_threshold=$2
filtering=$3
foci_text=$(find * -type f | grep -v 'tapisjob')

# Check foci text
if [ -n "${foci_text}" ];
then
    INPUT="${foci_text}"
else
	echo "Error: foci_text is undefined"
	exit
fi

# Get radius
if [ -n "${radius}" ];
then
    RADIUS="${radius}"
else
    RADIUS="6"
fi

# Get ALE threshold
if [ -n "${ale_threshold}" ];
then
    ALE_THRESHOLD="${ale_threshold}"
else
    ALE_THRESHOLD="75"
fi

# Get filtering
if [ -n "${filtering}" ];
then
    FILTER="${filtering}"
else
    FILTER="0"
fi


# Pull some assets out of container, input file needs to be in asset dir
cp -r /app/src/xGTM_portal .
cp -r /app/src/gtm.m .
mv ${foci_text} xGTM_portal/
chmod +rx xGTM_portal/${foci_text}


# Log commands, timing, run job
echo -n "starting: "
date
COMMAND=" /scratch/tacc/apps/matlab/2022b/bin/matlab "
PARAMS=" -nodesktop -nodisplay -nosplash "
MATLAB_FUNC="gtm ${PWD}/xGTM_portal/ ${foci_text} ${RADIUS} ${ALE_THRESHOLD} ${FILTER}"
echo "================================================================"
echo "COMMAND = ${COMMAND} ${PARAMS} -r ' ${MATLAB_FUNC} ' "
echo "================================================================"
${COMMAND} ${PARAMS} -r " ${MATLAB_FUNC} "


# Assemble and clean up output
mkdir output/
_FOCI_TEXT="${foci_text}"
mv xGTM_portal/${_FOCI_TEXT} ./
mv xGTM_portal/${_FOCI_TEXT%.*}* ./output/

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

rm -rf xGTM_portal/
rm gtm.m

echo -n "ending: "
date

