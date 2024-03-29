#!/bin/bash
# LT Strike
# Requires FSL
# Quick method to produce MP2RAGE UNIT1 image with some background noise removed (based on a mask created from thresholding the inv-2 image)
# Doesn't work for all registration and segmentation algorithms (i.e., too much background noise remains)
# Usage: inv-2_mask.sh [participant_id]

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a participant_id'
    exit 0
fi

# Local (Neurodesk https://www.neurodesk.org/)
ml fsl/6.0.5.1
data_dir=/neurodesktop-storage/qtab_bids
output_dir="$data_dir"/derivatives/MP2RAGE_preprocessing
code_dir=/neurodesktop-storage/github/anat

participantID="$*"
ses="ses-01"

# Organise the data
echo Now running "$participantID"
cd "$data_dir"
mkdir -p "$data_dir"/derivatives/MP2RAGE_preprocessing/"$participantID"
cp "$data_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_inv-2_MP2RAGE.nii.gz "$output_dir"/"$participantID"
cp "$data_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_UNIT1.nii.gz "$output_dir"/"$participantID"
cd "$output_dir"/"$participantID" || exit

# Create brainmask by thresholding the inv-2 image (increase the threshold number to remove more background - but be careful not to increase so much that brain is included in the mask)
fslmaths "$participantID"_"$ses"_inv-2_MP2RAGE.nii.gz -thr 80 -bin "$participantID"_"$ses"_inv-2_MP2RAGE_mask
fslmaths "$participantID"_"$ses"_UNIT1.nii.gz -mul "$participantID"_"$ses"_inv-2_MP2RAGE_mask "$participantID"_"$ses"_UNIT1_masked

# Cleanup
rm -f "$participantID"_"$ses"_UNIT1.nii.gz
rm -f "$participantID"_"$ses"_inv-2_MP2RAGE.nii.gz
rm -f "$participantID"_"$ses"_inv-2_MP2RAGE_mask.nii.gz

echo "$participantID" is complete