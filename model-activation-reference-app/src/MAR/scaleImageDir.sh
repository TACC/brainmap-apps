#!/bin/bash

# the input directory, should contain floating point images (*.nii.gz)
input=$1

# the output directory, will contain images scaled up to fit in data-range
# originally a sub-directory, moved up - so use a new name ($1 != $2)
output=$2

# parameters: 1st = input, 2nd = output
# -b/-c = 1 byte output (default), -s = 2 byte output
# -n = no scaling
# -d/-v = debug/verbose

# default options
VERBOSE=""
IMAGE_TYPE="char"
NO_SCALE=""

# check parameters
for arg in $*;
do
	if [[ $arg = "-d" || $arg = "-debug" || $arg = "-v" || $arg = "-verbose" ]]
	then
		VERBOSE="true"
	fi
	
	if [[ $arg = "-n" || $arg = "-no" || $arg = "-noscale" || $arg = "-noscaling" ]]
	then
		NO_SCALE="true"
	fi
	
	if [[ $arg = "-b" || $arg = "-byte" || $arg = "-c" || $arg = "-char" ]]
	then
		IMAGE_TYPE="char"
	fi
	
	if [[ $arg = "-s" || $arg = "-short" ]]
	then
		IMAGE_TYPE="short"
	fi
	
	if [[ $arg = "-f" || $arg = "-float" ]]
	then
		IMAGE_TYPE="float"
	fi
done;

# set scaled max value by the data type
# allow some room for rounding errors (don't use actual max)
SCALED_MAX=""
if [[ $IMAGE_TYPE = "byte" && ! $NO_SCALE ]]
then
	SCALED_MAX="250"
fi
if [[ $IMAGE_TYPE = "short" && ! $NO_SCALE ]]
then
	# short was being treated as signed, so only go up to positive short max
	SCALED_MAX="32000"
fi
if [[ $IMAGE_TYPE = "float" && ! $NO_SCALE ]]
then
	# short was being treated as signed, so only go up to positive short max
	SCALED_MAX="100000"
fi

# drop down into input directory
cd $input

# create sub-directory
mkdir -p $output

# scaling requires getting the maximum value
if [[ ! $NO_SCALE ]]
then
	
	# feedback
	if [[ $VERBOSE ]]
	then
		echo "scaleImageDir finding max: \c"
	fi
	
	# run through each image and save the max value
	maxval=0
	for e in *.nii.gz
	do
		# get image max
		max_e=`fslstats $e -P 100`
		
		# get overall max value
		if [ `echo "$maxval < $max_e"` ]
		then
			maxval=$max_e
		fi
		
		# feedback
		if [[ $VERBOSE ]]
		then
			echo ".\c"
		fi
	done
	if [[ $VERBOSE ]]
	then
		echo ""
	fi
	
	# find scaling factor that best fits max value into scaled maximum
	scaling=`echo "0 k $SCALED_MAX $maxval / p" | dc -`
	
	# feedback
	#if [[ $VERBOSE ]]
	#then
		echo "scaleImageDir $input max $maxval * $scaling ~= $SCALED_MAX $IMAGE_TYPE"
	#fi
fi

if [[ $VERBOSE ]]
then
	if [[ $NO_SCALE ]]
	then
		echo "scaleImageDir changing image type: \c"
	else
		echo "scaleImageDir scaling: \c"
	fi
fi
# for each image
for e in *.nii.gz
do
  
	if [[ ! $NO_SCALE ]]
	then
		# multiply by scaling factor and use designated image type
		fslmaths $e -mul $scaling ${output}/$e -odt $IMAGE_TYPE
	else
		# just re-save as new data type
		fslmaths $e ${output}/$e -odt $IMAGE_TYPE
	fi
	
	# feedback
	if [[ $VERBOSE ]]
	then
		echo ".\c"
	fi
done
if [[ $VERBOSE ]]
then
  echo ""
fi

# move sub-directory to same level
mv $output ..
