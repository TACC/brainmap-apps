#!/bin/bash
set -e

# Allow over-ride
# if [ -z "${CONTAINER_IMAGE}" ]
# then
#     version=$(cat ./_util/VERSION)
#     CONTAINER_IMAGE="index.docker.io/library/ubuntu:bionic"
# fi
# . lib/container_exec.sh
# 
# 
# COMMAND="melodic"
# 
# INPUTS=" -i ${4dimage} "
# 
# 
# OPTS=""
# 
# if [ -n "${mask_file}" ];
# then
#   OPTS="${OPTS} -m masks/${mask_file} "
# 
# else
#   echo "must specify mask file"
#   exit 1
# 
# fi
# 
# 
# if [ -n "${dim_red}" ];
# then
#   OPTS="${OPTS} -d ${dim_red} "
# 
# else
#   OPTS="${OPTS} -d 20 "
# 
# fi
# 
# OPTS="${OPTS} -a concat --vn --Oall --report "
# 
# echo "container_exec ${CONTAINER_IMAGE} ${COMMAND} ${INPUTS} ${OPTS}"
# container_exec ${CONTAINER_IMAGE} $COMMAND $INPUTS $OPTS

tar -xzf input.tar.gz
mkdir -p temp1/ temp2/ output/

# Step 1: Get Activation Maps
REF="-tal"   # can be -tal or -mni
MASK="masks/Tal_wb_dil.nii.gz"   # can be MNI152_wb.nii.gz, MNI152_wb_dil.nii.gz, Tal_wb.nii.gz, Tal_wb_dil.nii.gz

for FILE in input/*
do
	docker run --rm -v $PWD:/test -w /test wjallen/ica:1.0.0 \
                                           java -cp /app/GingerALE.jar org.brainmap.meta.getActivationMap \
        	                          -expanded -gzip $REF -mask=$MASK $FILE
        NEW_FILE=$( basename $FILE .txt )
        mv input/${NEW_FILE}_ALE.nii.gz temp1/
done


# Step 2: Scale Images
IMAGE_TYPE="short"
SCALED_MAX="32000"
MAX_VAL=0

for FILE in temp1/*.nii.gz
do
	THIS_VAL=` docker run --rm -v ${PWD}:/test -w /test wjallen/ica:1.0.0 ${CONTAINER_IMAGE} fslstats ${FILE} -P 100 `
	echo "THIS_VAL = ${THIS_VAL}"
	if (( $(echo "$THIS_VAL > $MAX_VAL" | bc -l) )); then
		MAX_VAL=$THIS_VAL
	fi
done

SCALING=` echo "0 k $SCALED_MAX $MAX_VAL / p" | /usr/bin/dc - `
echo "SCALING = $SCALING"

for FILE in temp1/*.nii.gz
do
	FILE_BN=$( basename $FILE )
	docker run --rm -v $PWD:/test -w /test wjallen/ica:1.0.0 \
			fslmaths $FILE -mul $SCALING temp2/$FILE_BN -odt $IMAGE_TYPE
done

# Step 3: Merge Images
export LC_ALL=C
for IMAGE in temp2/*.nii.gz
do
	echo $IMAGE >> output/mod_4d.txt
done

docker run --rm -v $PWD:/test -w /test wjallen/ica:1.0.0 \
		fslmerge -t output/mod_4d.nii.gz temp2/*nii.gz


rm -rf input temp1 temp2

# Step 4: Do ICA with Melodic
docker run --rm -v $PWD:/test -w /test wjallen/ica:1.0.0 \
	melodic -i output/mod_4d.nii.gz -d 2 -m ${MASK} --vn --Oall --report



