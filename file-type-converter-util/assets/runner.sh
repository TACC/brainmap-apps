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

mv ${output_filename} tmp_file_no_headers

# chop output back together with input
while IFS= read -r line; do
    if [[ $line == "// Reference=MNI" ]]; then
        echo "// Reference=Talairach" >> "${output_filename}"
    elif [[ $line == "// Reference=T"* ]]; then
        echo "// Reference=MNI" >> "${output_filename}"
    elif [[ $line == "/"* ]] || [[ -z $line ]]; then
        echo "$line" >> "${output_filename}"
    elif [[ $line == [0-9]* ]] || [[ $line == "-"* ]]; then
        other_line=$(head -n 1 "tmp_file_no_headers")
        echo "$other_line" >> "${output_filename}"
        tail -n +2 tmp_file_no_headers > tmp_tmp_tmp && mv tmp_tmp_tmp tmp_file_no_headers  # use tail to remove first line from second file - a bit faster than sed
    fi
done < ${input_file}


rm ${SING_IMG}
rm ${transform}.m readTSV.m writeTSV.m
rm tmp_file_no_headers
mv ${input_file} COPY_OF_${input_file}
# rm ${input_file}


echo -n "ending: "
date
