#!/bin/bash

# takes directory of foci & reference space (-tal or -mni)
# ../make_sampleNiftis_byRois
DIR_ALES=$1
# ../make_sampleNiftis_byRois/spheres_2mm
DIR_ROIS=$2
# L_MDN
TITLE=$3

# current_roi="${ROI_FILE%%_2mmVox_bin.nii.gz}"
# ROI_NAME=`echo "$ROI_FILE" | cut -d'.' -f1`
# filename=$(basename -- "$fullfile")
# extension="${filename##*.}"
# filename="${filename%.*}"

for ALE_FILE in ${DIR_ALES}/raw_ALE/*.nii
do
    ALE_FILE_NOPATH="${ALE_FILE##*/}"
    ALE_NAME="${ALE_FILE_NOPATH%%_ALE.nii}"
    echo "Sampling ALE values at all ROIs from $ALE_FILE_NOPATH"
    for ROI_FILE in ${DIR_ROIS}/*2mmVox_bin.nii.gz
    do
        ROI_FILE_NOPATH="${ROI_FILE##*/}"
        ROI_NAME="${ROI_FILE_NOPATH%%_2mmVox_bin.nii.gz}"
        fslmeants -i $ALE_FILE -m $ROI_FILE -o ${DIR_ALES}/meants_roi_ALE_SAMPLING_${ROI_NAME}.txt
        # paste ${DIR_ALES}/meants_roi_ALE_SAMPLING*.txt >> ${DIR_ALES}/allmeants_roi_ALE_SAMPLEDfrom_${ALE_NAME}.txt
    done
    paste ${DIR_ALES}/meants_roi_ALE_SAMPLING*.txt > ${DIR_ALES}/allmeants_roi_ALE_SAMPLEDfrom_${ALE_NAME}.txt
    paste ${DIR_ALES}/allmeants_roi_ALE_SAMPLEDfrom_${ALE_NAME}.txt >> ${DIR_ALES}/${TITLE}_macm-ale-samples.txt
done
# paste ${DIR_ALES}/allmeants_roi_ALE_SAMPLEDfrom_*.txt > ${DIR_ALES}/macm-ale-samples.txt

for PVAL_FILE in ${DIR_ALES}/raw_PVal/*.nii
do
    PVAL_FILE_NOPATH="${PVAL_FILE##*/}"
    PVAL_NAME="${PVAL_FILE_NOPATH%%_PVal.nii}"
    echo "Sampling  P values at all ROIs from $PVAL_FILE_NOPATH"
    for ROI_FILE in ${DIR_ROIS}/*2mmVox_bin.nii.gz
    do
        ROI_FILE_NOPATH="${ROI_FILE##*/}"
        ROI_NAME="${ROI_FILE_NOPATH%%.*}"
        fslmeants -i $PVAL_FILE -m $ROI_FILE -o ${DIR_ALES}/meants_roi_PVal_${ROI_NAME}.txt
        # paste ${DIR_ALES}/meants_roi_PVal*.txt >> ${DIR_ALES}/allmeants_roi_PVal_SAMPLEDfrom_${PVAL_NAME}.txt
    done
    # trash2
    paste ${DIR_ALES}/meants_roi_PVal*.txt > ${DIR_ALES}/allmeants_roi_PVal_SAMPLEDfrom_${PVAL_NAME}.txt
    paste ${DIR_ALES}/allmeants_roi_PVal_SAMPLEDfrom_${PVAL_NAME}.txt >> ${DIR_ALES}/${TITLE}_macm-Pval-samples.txt
done
# trash1
# paste ${DIR_ALES}/allmeants_roi_PVal_SAMPLEDfrom_*.txt > ${DIR_ALES}/macm-Pval-samples.txt 

for Z_FILE in ${DIR_ALES}/raw_Z/*.nii
do
    Z_FILE_NOPATH="${Z_FILE##*/}"
    Z_NAME="${Z_FILE_NOPATH%%.*}"
    echo "Sampling Z values at all ROIs from $Z_FILE_NOPATH"
    for ROI_FILE in ${DIR_ROIS}/*.nii.gz
    do
        ROI_FILE_NOPATH="${ROI_FILE##*/}"
        ROI_NAME="${ROI_FILE_NOPATH%%_Z.nii}"
        fslmeants -i $Z_FILE -m $ROI_FILE -o ${DIR_ALES}/meants_roi_Z_${ROI_NAME}.txt
        
        # paste ${DIR_ALES}/meants_roi_Z*.txt >> ${DIR_ALES}/allmeants_roi_Z_SAMPLEDfrom_${Z_NAME}.txt
    done
    paste ${DIR_ALES}/meants_roi_Z*.txt > ${DIR_ALES}/allmeants_roi_Z_SAMPLEDfrom_${Z_NAME}.txt
    paste ${DIR_ALES}/allmeants_roi_Z_SAMPLEDfrom_${Z_NAME}.txt >> ${DIR_ALES}/${TITLE}_macm-Z-samples.txt
done
# paste ${DIR_ALES}/allmeants_roi_Z_SAMPLEDfrom_*.txt > ${DIR_ALES}/macm-Z-samples.txt

# find . -name 'meants_*.txt' -exec rm {} \;
# find . -name 'allmeants_*.txt' -exec rm {} \;
