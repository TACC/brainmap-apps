#!/bin/bash

sector=$1
radius=$2
coord_space=$3
mask_size=$4
seed_rois=$(find * -type f | grep -v 'tapisjob')
ref_path="/work/08531/brainmap/tapis/data/macm/2023-12-05"

# Check seed rois
if [ -n "${seed_rois}" ];
then
    INPUT="${foci_text}"
    INPUT_ROIS=${seed_rois}
    INPUT_ROIS_BN="$(echo ${seed_rois} | cut -d '.' -f1 )"
else
	echo "Error: seed_rois is undefined"
	exit
fi

# sector - can be vbm, vbp, or ta
if [ -n "${sector}" ];
then
    DB_SECTOR="${sector}"
else
    DB_SECTOR="vbm"
fi

# radius - 6mm for fmacm, 4mm for smacm
if [ -n "${radius}" ];
then
    RADIUS="${radius}"
else
    RADIUS="4"
fi

# coord_space can be Tal_wb or MNI152_wb
if [[ "${coord_space}" == "Tal_wb" ]];
then
    COORD_FORMAT="tal"
    COORD_FORMAT_FOR_SPHERES="-tal"
else
    COORD_FORMAT="mni"
    COORD_FORMAT_FOR_SPHERES=""
fi

# Add Mask File
MASK_FILE="${coord_space}${mask_size}"

REF_COORDS_BN=ref_coords_${DB_SECTOR}_${COORD_FORMAT}    # these are hidden in portal interface
REF_COORDS=${ref_path}/${REF_COORDS_BN}.tar.gz
REF_IMAGES_BN=ref_images_${DB_SECTOR}_${COORD_FORMAT}    # these are hidden in portal interface
REF_IMAGES=${ref_path}/${REF_IMAGES_BN}.tar.gz


# Unpack inputs
tar -xzf ${REF_COORDS} -C /tmp/
ln -s /tmp/${REF_COORDS_BN} ref_coords   # so voxelwise.py can link to just 'ref_coords' and hit the correct one
tar -xzf ${REF_IMAGES} -C /tmp/
ln -s /tmp/${REF_IMAGES_BN} ref_images

OUTPUT="output"
mkdir ${OUTPUT}


# Step 0: Generate ROIs from Coords       # pull this out and make it a utility later
# will generate a bunch of nii.gz text files in the output folder
#CMD0="bash /MACM/coords_j_1mm_goodRegExp.sh"
#OPT0="${INPUT} ${RADIUS} MNI152_T1_1mm_brain.nii.gz output "
#echo "================================================================"
#echo -n "starting step 1: Split experiments, "
#date
#echo "COMMAND0 = singularity exec ${SING_IMG} ${CMD0} ${OPT0}"
#echo "================================================================"
#singularity --quiet exec ${SING_IMG} ${CMD0} ${OPT0}

# input 1: text file name
# input 2: radius
# inpur 3: label / identifier


# Step 1: Create images for each ROI
cp /app/src/MACM/spheres.py .  # spheres.py wants to be in local dir
cp -r /app/src/masks .
CMD1=" python3 spheres.py "
OPT1=" ${COORD_FORMAT_FOR_SPHERES} -r=${RADIUS} ${INPUT_ROIS} "
echo "================================================================"
echo -n "Starting step 1: Generating images from ROIs, "
date
echo "COMMAND = ${CMD1} ${OPT1}"
echo "================================================================"
${CMD1} ${OPT1}


# Step 2: Identify overlapping coordinates from appropriate database
cp /app/src/MACM/voxelwise.py .  # voxelwise.py wants to be in local dir
CMD2=" python3 voxelwise.py "
OPT2=" ref_images/mar_4d -1d ${INPUT_ROIS_BN}/*.nii.gz "
echo "================================================================"
echo -n "Starting step 2: Identifying coordinates for MACM, "
date
echo "COMMAND = ${CMD2} ${OPT2}"
echo "================================================================"
${CMD2} ${OPT2}


echo ""
echo "================================================================"
echo "LOOPING STEP 3 FOR ANNOTATION FILES"
echo "================================================================"
echo ""

# Loop step 3 over all Annotations
for ANNOTATION_FILE in ` ls ${INPUT_ROIS_BN} | grep nii.gz | awk -F. '{print $1}' `
do

# Step 3: Run GingerALE MA on resulting text to get ALE image
PRE3=" numactl -C 0-7 "
CMD3=" java -cp /app/src/GingerALE.jar org.brainmap.meta.getALE2 "
OPT3=" ${INPUT_ROIS_BN}/${ANNOTATION_FILE}_macm.txt -fwe=0.05 -perm=5000 -minVol=9 -mask=masks/${MASK_FILE} -nonAdd "
echo "================================================================"
echo -n "Starting step 3: Running GingerALE to produce MA maps, "
date
echo "COMMAND = ${PRE3} ${CMD3} ${OPT3}"
echo "================================================================"
${PRE3} ${CMD3} ${OPT3} 


done # end for each ANNOTATION_FILE


# Step 4: Run cross correlation of ALEs and ROIs
echo "================================================================"
echo -n "Starting step 4: Running cross correlation, "
date
echo "COMMAND = fslmeants -i ALE -m ROI"
echo "================================================================"
for ALE_FILE in ` ls ${INPUT_ROIS_BN} | grep FWE | grep ALE.nii `
do
    echo "Sampling ALE values at all ROIs from $ALE_FILE"
    for ROI_FILE in ` ls ${INPUT_ROIS_BN} | grep nii.gz `
    do
        fslmeants -i ${INPUT_ROIS_BN}/$ALE_FILE -m ${INPUT_ROIS_BN}/$ROI_FILE -o ${OUTPUT}/meants_roi_ALE_SAMPLING_${ROI_FILE%.nii.gz}.txt
    done
    paste ${OUTPUT}/meants_roi_ALE_SAMPLING*.txt > ${OUTPUT}/allmeants_roi_ALE_SAMPLED_from_${ALE_FILE%.nii}.txt
    paste ${OUTPUT}/allmeants_roi_ALE_SAMPLED_from_${ALE_FILE%.nii}.txt >> ${OUTPUT}/final_macm_ale_samples.txt
done
for PVAL_FILE in ` ls ${INPUT_ROIS_BN} | grep PVal.nii `
do
    echo "Sampling P Values at all ROIs from $PVAL_FILE"
    for ROI_FILE in ` ls ${INPUT_ROIS_BN} | grep nii.gz `
    do
        fslmeants -i ${INPUT_ROIS_BN}/$PVAL_FILE -m ${INPUT_ROIS_BN}/$ROI_FILE -o ${OUTPUT}/meants_roi_PVal_${ROI_FILE%.nii.gz}.txt
    done
    paste ${OUTPUT}/meants_roi_PVal*.txt > ${OUTPUT}/allmeants_roi_PVal_SAMPLED_from_${PVAL_FILE%.nii}.txt
    paste ${OUTPUT}/allmeants_roi_PVal_SAMPLED_from_${PVAL_FILE%.nii}.txt >> ${OUTPUT}/final_macm_pval_samples.txt
done
for Z_FILE in ` ls ${INPUT_ROIS_BN} | grep FWE | grep Z.nii `
do
    echo "Sampling Z Values at all ROIs from $Z_FILE"
    for ROI_FILE in ` ls ${INPUT_ROIS_BN} | grep nii.gz `
    do
        fslmeants -i ${INPUT_ROIS_BN}/$Z_FILE -m ${INPUT_ROIS_BN}/$ROI_FILE -o ${OUTPUT}/meants_roi_Z_${ROI_FILE%.nii.gz}.txt
    done
    paste ${OUTPUT}/meants_roi_Z*.txt > ${OUTPUT}/allmeants_roi_Z_SAMPLED_from_${Z_FILE%.nii}.txt
    paste ${OUTPUT}/allmeants_roi_Z_SAMPLED_from_${Z_FILE%.nii}.txt >> ${OUTPUT}/final_macm_Z_samples.txt
done


# Step 5: Generate heatmap
# need non-interactive version of heatmap_of_batch_macm.m


# Step 6: Clean up
echo "================================================================"
echo -n "Cleaning up, "
date

rm ref_images
rm ref_coords

rm -rf /tmp/${REF_COORDS_BN}
rm -rf /tmp/${REF_IMAGES_BN}

rm voxelwise.py
rm spheres.py
rm -rf masks/

rm ${OUTPUT}/meants*

echo -n "Done: "
date
echo "================================================================"
