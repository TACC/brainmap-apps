#!/bin/bash

transform=$1
output_filename=$2
foci_text=$(find * -type f | grep -v 'tapisjob')

COMMAND=" /scratch/tacc/apps/matlab/2022b/bin/matlab "
PARAMS=" -nodesktop -nodisplay -nosplash "
MATLAB_FUNC=" "

# Get transform
if [ -n "${transform}" ];
then
    MATLAB_FUNC=" ${MATLAB_FUNC} ${transform} "
else
    MATLAB_FUNC=" ${MATLAB_FUNC} icbm_spm2tal "
fi

# Check foci text
if [ -n "${foci_text}" ];
then
    MATLAB_FUNC=" ${MATLAB_FUNC} ${foci_text} "
else
	echo "Error: foci_text is undefined"
	exit
fi

# Get output filename
if [ -n "${output_filename}" ];
then
    MATLAB_FUNC=" ${MATLAB_FUNC} ${output_filename} "
else
    MATLAB_FUNC=" ${MATLAB_FUNC} output.txt "
fi


# Pull some assets out of container, input file needs to be in same dir
cp /app/src/${transform}.m ./
cp /app/src/readTSV.m ./
cp /app/src/writeTSV.m ./

# Log commands, timing, run job
echo -n "starting: "
date

echo "================================================================"
echo "COMMAND = ${COMMAND} ${PARAMS} -r ' ${MATLAB_FUNC} ' "
echo "================================================================"
${COMMAND} ${PARAMS} -r " ${MATLAB_FUNC} "

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

rm ${transform}.m readTSV.m writeTSV.m
rm tmp_file_no_headers
mv ${input_file} COPY_OF_${input_file}

echo -n "ending: "
date
