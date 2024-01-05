#!/bin/bash

foci_text=$(find * -type f | grep -v 'tapisjob')

# Grab foci text from user, must be special MNI format with annotations
if [ -n "${foci_text}" ];
then
	ENVIRON=" --env foci_text=${foci_text} "
else
	echo "Error: must specify foci text"
	exit
fi

COMMAND="  /scratch/tacc/apps/matlab/2022b/bin/matlab "
PARAMS=" -nodesktop -nodisplay -nosplash "
PARAMS=" ${PARAMS} < /app/src/matlab_wrapper.m "

# Log commands, timing, run job
echo -n "starting: "
date

echo "================================================================"
echo "COMMAND = foci_text=${foci_text} ${COMMAND} ${PARAMS}"
echo "================================================================"
foci_text=${foci_text} ${COMMAND} ${PARAMS}

echo "================================================================"
echo "Removing the following intermediate files:"
echo "  ./data/ActivationVolumes/*.nii"
echo "  ./data/BinarySmoothedVolumes/*.nii"
echo "  ./outputs/K1/alpha100_eta0.01/*.mat"
echo "  ./outputs/K2/alpha100_eta0.01/*.mat"
echo "  ./outputs/K3/alpha100_eta0.01/*.mat"
echo "  ./outputs/K4/alpha100_eta0.01/*.mat"
echo "================================================================"

rm -f ./data/ActivationVolumes/*.nii
rm -f ./data/BinarySmoothedVolumes/*.nii
rm -f ./outputs/K1/alpha100_eta0.01/*.mat
rm -f ./outputs/K2/alpha100_eta0.01/*.mat
rm -f ./outputs/K3/alpha100_eta0.01/*.mat
rm -f ./outputs/K4/alpha100_eta0.01/*.mat

echo -n "ending: "
date

