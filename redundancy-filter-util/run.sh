#!/bin/bash

filtering=$1
foci_text=$(find * -type f | grep -v 'tapisjob')

COMMAND=" /scratch/tacc/apps/matlab/2022b/bin/matlab "
PARAMS=" -nodesktop -nodisplay -nosplash "
MATLAB_FUNC=" make_per_experiment_TXTfiles_for_meta_ICA "

# set up temp dirs
OUTPUT="individual-files"
mkdir ${OUTPUT}

# Check foci text
if [ -n "${foci_text}" ];
then
    MATLAB_FUNC=" ${MATLAB_FUNC} ${foci_text} "
else
	echo "Error: foci_text is undefined"
	exit
fi

MATLAB_FUNC=" ${MATLAB_FUNC} ${PWD} "

# Get filtering
if [ -n "${filtering}" ];
then
    MATLAB_FUNC=" ${MATLAB_FUNC} ${filtering} "
else
    MATLAB_FUNC=" ${MATLAB_FUNC} 0 "
fi

# Pull some assets out of container, input file needs to be in same dir
cp /app/src/make_per_experiment_TXTfiles_for_meta_ICA.m ./

# Log commands, timing, run job
echo "================================================================"
echo -n "Starting: Filtering and parsing input, "
date
echo "COMMAND = ${COMMAND} ${PARAMS} -r ' ${MATLAB_FUNC} ' "
echo "================================================================"
cp /app/src/make_per_experiment_TXTfiles_for_meta_ICA.m ./
${COMMAND} ${PARAMS} -r " ${MATLAB_FUNC} "

# Print some info into output file
cat <<EOF
================================================================
README:
General output format:
    "MAindex_000000_pap_000000_exp_00_Authorlabel.txt"
    Naming scheme: 
       - index:       Overall experiment index 
                          (e.g. temp_it)
       - pap:         paper index 
                          (e.g. final_exp_filt_paper_index(temp_it) )
       - exp:         experiment index (within-paper) 
                          (e.g. exp_filt_pap_exp_ind )
       - Authorlabel: paper/year 
                          (e.g. final_exp_filt_paper_labels(temp_it) )
================================================================
EOF

# Clean up
mv per-experiment*/* ${OUTPUT}
rmdir per-experiment*
tar -czf ${OUTPUT}.tar.gz ${OUTPUT}
rm -rf ${OUTPUT}
rm make_per_experiment_TXTfiles_for_meta_ICA.m

echo -n "Done: "
date
