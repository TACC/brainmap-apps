# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
   version=$(cat ./_util/VERSION)
    CONTAINER_IMAGE="index.docker.io/library/ubuntu:bionic"
fi
. lib/container_exec.sh
module unload xalt
module load matlab

SING_IMG='ica_1.0.0.sif'
singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}
dos2unix ${input_file}

# Unpack user provided input tar.gz file
#date
#echo "Unpacking input tarball..."
#mkdir input/ temp1/ temp2/ output/
#tar -xzvf ${input_tarball} -C input --strip-components=1
#echo ""


# # Step 0: Filter and parse input
# date
# echo "Filtering and parsing input..."
# mkdir input/ temp1/ temp2/ output/
# singularity --quiet exec ${SING_IMG} cp /app/make_lists_experiment_files_v5 .
# matlab -nodesktop -nodisplay -nosplash < make_lists_experiment_files_v5 ${input_file}
# echo ""

# Step 0: Filter and parse input
date
echo "Filtering and parsing input..."
mkdir input/ temp1/ temp2/ output/
awk -v RS= '{print > ("input/data_" NR ".txt")}' ${input_file}


echo ""


# Step 1: Get Activation Maps
date
echo "Getting activation maps with GingerALE..."
REF="-${format}"   # can be -tal or -mni
MASK="masks/${mask_file}"   # can be MNI152_wb.nii.gz, MNI152_wb_dil.nii.gz, Tal_wb.nii.gz, Tal_wb_dil.nii.gz

for FILE in input/*
do
	singularity --quiet exec ${SING_IMG} java -cp /app/GingerALE.jar org.brainmap.meta.getActivationMap \
        	                             -expanded -gzip $REF -mask=$MASK $FILE
        NEW_FILE=$( basename $FILE .txt )
        mv input/${NEW_FILE}_ALE.nii.gz temp1/
done

find temp1/
echo ""

# Step 2: Scale Images
date
echo "Scaling images..."
IMAGE_TYPE="short"
SCALED_MAX="32000"
MAX_VAL=0

for FILE in temp1/*.nii.gz
do
	THIS_VAL=` singularity --quiet exec ${SING_IMG} fslstats ${FILE} -P 100 `
	echo "THIS_VAL = ${THIS_VAL}"
	if (( $(echo "$THIS_VAL > $MAX_VAL" | bc -l) )); then
		MAX_VAL=$THIS_VAL
	fi
done

SCALING=` echo "0 k $SCALED_MAX $MAX_VAL / p" | dc - `
echo "SCALING = $SCALING"

for FILE in temp1/*.nii.gz
do
	FILE_BN=$( basename $FILE )
	singularity --quiet exec ${SING_IMG} fslmaths $FILE -mul $SCALING temp2/$FILE_BN -odt $IMAGE_TYPE
done

find temp2/
echo ""

# Step 3: Merge Images
date
echo "Merging images..."
export LC_ALL=C
for IMAGE in temp2/*.nii.gz
do
	echo $IMAGE >> output/mod_4d.txt
done

singularity --quiet exec ${SING_IMG} fslmerge -t output/mod_4d.nii.gz temp2/*nii.gz

find output
echo ""




# Step 4: Do ICA with Melodic
date
echo "Performing ICA with melodic..."
DIMENSIONALITY="${dim_red}"
echo "dimensionality reduction = ${DIMENSIONALITY}"
singularity --quiet exec ${SING_IMG} melodic -i output/mod_4d.nii.gz -d ${DIMENSIONALITY} -m ${MASK} --vn --Oall --report

find output
echo ""

rm -rf input temp1 temp2


echo "Finished at:"
date
