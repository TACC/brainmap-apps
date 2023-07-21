# Allow over-ride
if [ -z "${CONTAINER_IMAGE}" ]
then
    CONTAINER_IMAGE="wjallen/macm:1.0.0"
fi

SING_IMG=$( basename ${CONTAINER_IMAGE} | tr ':' '_' )
SING_IMG="${SING_IMG}.sif"

# silence xalt errors
module unload xalt

# Step 0: Gather input
INPUT_ROIS=${seed_rois}
INPUT_ROIS_BN="$(echo ${seed_rois} | cut -d '.' -f1 )"

# sector - can be vbm, vbp, or ta
if [ -n "${sector}" ];
then
    DB_SECTOR="${sector}"
else
    DB_SECTOR="vbm"
fi

# radius - 6mm for fmacm, 4mm for smacm - or 2mm for all?
if [ -n "${radius}" ];
then
    RADIUS="${radius}"
else
    RADIUS="2"
fi

# Add Mask File
# can be MNI152_wb.nii.gz, MNI152_wb_dil.nii.gz, Tal_wb.nii.gz, Tal_wb_dil.nii.gz
MASK_FILE="${coord_space}${mask_size}"

if [[ "${coord_space}" == "Tal_wb" ]];
then
    COORD_FORMAT="tal"
	COORD_FORMAT_FOR_SPHERES="-tal"
else
    COORD_FORMAT="mni"
	COORD_FORMAT_FOR_SPHERES=""
fi


REF_COORDS_BN=ref_coords_${DB_SECTOR}_${COORD_FORMAT}    # these are hidden in portal interface
REF_COORDS=${ref_path}/${REF_COORDS_BN}.tar.gz
REF_IMAGES_BN=ref_images_${DB_SECTOR}_${COORD_FORMAT}    # these are hidden in portal interface
REF_IMAGES=${ref_path}/${REF_IMAGES_BN}.tar.gz

#REF_COORDS=${ref_coords}    # these are hidden in portal interface
#REF_COORDS_BN="$(echo ${ref_coords} | cut -d '.' -f1 )"
#REF_IMAGES=${ref_images}    # these are hidden in portal interface
#REF_IMAGES_BN="$(echo ${ref_images} | cut -d '.' -f1 )"


# Unpack inputs
tar -xzf ${REF_COORDS} -C /tmp/
ln -s /tmp/${REF_COORDS_BN} ref_coords   # so voxelwise.py can link to just 'ref_coords' and hit the correct one
tar -xzf ${REF_IMAGES} -C /tmp/
ln -s /tmp/${REF_IMAGES_BN} ref_images

OUTPUT="final_output"
mkdir ${OUTPUT}


# Log commands, timing, run job
echo "================================================================"
echo -n "Pulling container, "
date
echo "CONTAINER = singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}"
echo "================================================================"
singularity pull --disable-cache ${SING_IMG} docker://${CONTAINER_IMAGE}


# Step 1: Generate ROIs from Coords       # pull this out and make it a utility later
# will generate a bunch of nii.gz text files in the output folder
#CMD1="bash /MACM/coords_j_1mm_goodRegExp.sh"
#OPT1="${INPUT} ${RADIUS} MNI152_T1_1mm_brain.nii.gz output "
#echo "================================================================"
#echo -n "starting step 1: Split experiments, "
#date
#echo "COMMAND1 = singularity exec ${SING_IMG} ${CMD1} ${OPT1}"
#echo "================================================================"
#singularity --quiet exec ${SING_IMG} ${CMD1} ${OPT1}

# input 1: text file name
# input 2: radius
# inpur 3: label / identifier


# Step 1: Create images for each ROI
singularity exec ${SING_IMG} cp /MACM/spheres.py . # spheres.py wants to be in local dir
CMD1=" python3 spheres.py "
OPT1=" ${COORD_FORMAT_FOR_SPHERES} -r=${RADIUS} ${INPUT_ROIS} "
echo "================================================================"
echo -n "Starting step 1: Generating images from ROIs, "
date
echo "COMMAND = singularity exec ${SING_IMG} ${CMD1} ${OPT1}"
echo "================================================================"
singularity exec ${SING_IMG} ${CMD1} ${OPT1}


# Step 2: Identify overlapping coordinates from appropriate database
singularity exec ${SING_IMG} cp /MACM/voxelwise.py . # voxelwise.py wants to be in local dir
CMD2=" python3 voxelwise.py "
OPT2=" ref_images/mar_4d -1d ${INPUT_ROIS_BN}/*.nii.gz "
echo "================================================================"
echo -n "Starting step 2: Identifying coordinates for MACM, "
date
echo "COMMAND = singularity exec ${SING_IMG} ${CMD2} ${OPT2}"
echo "================================================================"
singularity exec ${SING_IMG} ${CMD2} ${OPT2}


echo ""
echo "================================================================"
echo "LOOPING STEP 3 FOR ANNOTATION FILES"
echo "================================================================"
echo ""

# Loop step 3 over all Annotations
for ANNOTATION_FILE in ` ls ${INPUT_ROIS_BN} | grep nii.gz | awk -F. '{print $1}' `
do

# Step 3: Run GingerALE MA on resulting text to get ALE image
CMD3=" java -cp /app/GingerALE.jar org.brainmap.meta.getALE2 "
OPT3=" ${INPUT_ROIS_BN}/${ANNOTATION_FILE}_macm.txt -fwe=0.05 -perm=5000 -minVol=9 -mask=masks/${MASK_FILE} -nonAdd "
echo "================================================================"
echo -n "Starting step 3: Running GingerALE to produce MA maps, "
date
echo "COMMAND = singularity exec ${SING_IMG} ${CMD3} ${OPT3}"
echo "================================================================"
numactl -C 0-7 singularity exec ${SING_IMG} ${CMD3} ${OPT3}


done # end for each ANNOTATION_FILE


# Step 4: Run cross correlation of ALEs and ROIs
echo "================================================================"
echo -n "Starting step 4: Running cross correlation, "
date
echo "COMMAND = singularity exec ${SING_IMG} fslmeants -i ALE -m ROI"
echo "================================================================"
for ALE_FILE in ` ls ${INPUT_ROIS_BN} | grep FWE | grep ALE.nii `
do
    echo "Sampling ALE values at all ROIs from $ALE_FILE"
    for ROI_FILE in ` ls ${INPUT_ROIS_BN} | grep nii.gz `
    do
        singularity exec macm_1.0.0.sif fslmeants -i ${INPUT_ROIS_BN}/$ALE_FILE -m ${INPUT_ROIS_BN}/$ROI_FILE -o ${OUTPUT}/meants_roi_ALE_SAMPLING_${ROI_FILE%.nii.gz}.txt
    done
    paste ${OUTPUT}/meants_roi_ALE_SAMPLING*.txt > ${OUTPUT}/allmeants_roi_ALE_SAMPLED_from_${ALE_FILE%.nii}.txt
    paste ${OUTPUT}/allmeants_roi_ALE_SAMPLED_from_${ALE_FILE%.nii}.txt >> ${OUTPUT}/final_macm_ale_samples.txt
done
for PVAL_FILE in ` ls ${INPUT_ROIS_BN} | grep PVal.nii `
do
    echo "Sampling P Values at all ROIs from $PVAL_FILE"
    for ROI_FILE in ` ls ${INPUT_ROIS_BN} | grep nii.gz `
    do
        singularity exec macm_1.0.0.sif fslmeants -i ${INPUT_ROIS_BN}/$PVAL_FILE -m ${INPUT_ROIS_BN}/$ROI_FILE -o ${OUTPUT}/meants_roi_PVal_${ROI_FILE%.nii.gz}.txt
    done
    paste ${OUTPUT}/meants_roi_PVal*.txt > ${OUTPUT}/allmeants_roi_PVal_SAMPLED_from_${PVAL_FILE%.nii}.txt
    paste ${OUTPUT}/allmeants_roi_PVal_SAMPLED_from_${PVAL_FILE%.nii}.txt >> ${OUTPUT}/final_macm_pval_samples.txt
done
for Z_FILE in ` ls ${INPUT_ROIS_BN} | grep FWE | grep Z.nii `
do
    echo "Sampling Z Values at all ROIs from $Z_FILE"
    for ROI_FILE in ` ls ${INPUT_ROIS_BN} | grep nii.gz `
    do
        singularity exec macm_1.0.0.sif fslmeants -i ${INPUT_ROIS_BN}/$Z_FILE -m ${INPUT_ROIS_BN}/$ROI_FILE -o ${OUTPUT}/meants_roi_Z_${ROI_FILE%.nii.gz}.txt
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

#rm ${REF_COORDS}
#rm ${REF_IMAGES}

rm -rf /tmp/${REF_COORDS_BN}
rm -rf /tmp/${REF_IMAGES_BN}

rm macm_1.0.0.sif
rm voxelwise.py
rm spheres.py
rm -rf masks/

rm ${OUTPUT}/meants*

echo -n "Done: "
date
echo "================================================================"
