# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    CONTAINER_IMAGE="wjallen/file-type-converter:1.0.0"
fi

SING_IMG=$( basename ${CONTAINER_IMAGE} | tr ':' '_' )
SING_IMG="${SING_IMG}.sif"
singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}

_INPUT_FILE=${input_file}
_TRANSFORM=${transform}
_OUTPUT_FILENAME=${output_filename}

# Silence xalt errors
module unload xalt

# Needed for matlab
BINDPATH=" --bind /opt/intel:/opt/intel "

COMMAND=" /scratch/tacc/apps/matlab/2022b/bin/matlab "
PARAMS=" -nodesktop -nodisplay -nosplash "
MATLAB_FUNC=" ${transform} ${input_file} ${output_filename} "

# Pull some assets out of container, input file needs to be in same dir
singularity exec ${SING_IMG} cp /src/${transform}.m .
singularity exec ${SING_IMG} cp /src/readTSV.m .
singularity exec ${SING_IMG} cp /src/writeTSV.m .

# Log commands, timing, run job
echo -n "starting: "
date

echo "================================================================"
echo "CONTAINER = singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}"
echo "================================================================"
echo "COMMAND = singularity exec ${BINDPATH} ${SING_IMG} ${COMMAND} ${PARAMS} -r ' ${MATLAB_FUNC} ' "
echo "================================================================"

singularity exec ${BINDPATH} ${SING_IMG} ${COMMAND} ${PARAMS} -r " ${MATLAB_FUNC} "

mv ${output_filename} temp_temp_temp.txt


# TODO if first line contains 'MNI' replace with 'Talairach' and vice versa

# chop output back together with input
while IFS= read -r line; do
  if [[ $line == "/"* ]] || [[ -z $line ]]; then
    echo "$line" >> "${output_filename}"
  elif [[ $line == [0-9]* ]]; then
    other_line=$(head -n 1 "temp_temp_temp.txt")
    echo "$other_line" >> "${output_filename}"
    sed -i '1d' "temp_temp_temp.txt"  # Remove the first line from the second file
  elif [[ $line == "-"* ]]; then
    other_line=$(head -n 1 "temp_temp_temp.txt")
    echo "$other_line" >> "${output_filename}"
    sed -i '1d' "temp_temp_temp.txt"  # Remove the first line from the second file
  fi
done < ${input_file}


rm ${SING_IMG}
rm ${transform}.m readTSV.m writeTSV.m
rm temp_temp_temp.txt
mv ${input_file} COPY_OF_${input_file}
# rm ${input_file}


echo -n "ending: "
date
