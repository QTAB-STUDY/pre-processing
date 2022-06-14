#!/bin/bash
# LT Strike
# Requires ANTS, FSL
# Produce brain extracted MP2RAGE (based on inv-2 - excessive background noise in UNIT1 image typically causes registration and segmentation algorithms to fail)
# Uses paediatric template:
# VS Fonov, AC Evans, K Botteron, CR Almli, RC McKinstry, DL Collins and BDCG, Unbiased average age-appropriate atlases for pediatric studies, NeuroImage, In Press, ISSN 1053–8119, DOI:10.1016/j.neuroimage.2010.07.033
# VS Fonov, AC Evans, RC McKinstry, CR Almli and DL Collins Unbiased nonlinear average age-appropriate brain templates from birth to adulthood NeuroImage, Volume 47, Supplement 1, July 2009, Page S102 Organization for Human Brain Mapping 2009 Annual Meeting, DOI: 10.1016/S1053-8119(09)70884-5
# Available from http://nist.mni.mcgill.ca/pediatric-atlases-4-5-18-5y/
# The 7-11 years template works well, but there are template for older age ranges 
# Be sure to always QC the brain extracted image!
# Usage: inv-2_brain_extraction.sh [participant_id]

# Local (Neurodesk https://www.neurodesk.org/)
ml ants/2.3.5
ml fsl/6.0.5.1
data_dir=/neurodesktop-storage/qtab_bids
output_dir="$data_dir"/derivatives/MP2RAGE_preprocessing

participantID="$@"
ses=ses-01

# Organise the data
echo Now running "$participantID"
cd "$data_dir"
mkdir -p "$data_dir"/derivatives/MP2RAGE_preprocessing/"$participantID"
cp "$data_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_inv-2_MP2RAGE.nii.gz "$output_dir"/"$participantID"
cp "$data_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_UNIT1.nii.gz "$output_dir"/"$participantID"
cd "$output_dir"/"$participantID" || exit

# Bias correct the inv-2 image (ANTS)
N4BiasFieldCorrection -i "$participantID"_"$ses"_inv-2_MP2RAGE.nii.gz -o "$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected.nii.gz

# Use fsl standard_space_roi to create a brain mask (based on the inv-2 image)
standard_space_roi "$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected.nii.gz ssroi_"$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected.nii.gz -ssref "$code_dir"/nihpd_sym_07.0-11.0_t1w.nii -maskMASK "$code_dir"/nihpd_sym_07.0-11.0_mask.nii -roiNONE # 7 - 11 years atlas
bet ssroi_"$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected.nii.gz "$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected_brain.nii.gz -f 0.15 -m
fslmaths "$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected_brain_mask.nii.gz -ero "$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected_brain_mask_ero.nii.gz

# Apply brain mask to the UNIT1 image
fslmaths "$participantID"_"$ses"_UNIT1.nii.gz -mul "$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected_brain_mask_ero.nii.gz "$participantID"_"$ses"_UNIT1_brain.nii.gz

# Cleanup
rm -f ssroi_"$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected.nii.gz
rm -f "$participantID"_"$ses"_UNIT1.nii.gz
rm -f "$participantID"_"$ses"_inv-2_MP2RAGE.nii.gz
rm -f "$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected.nii.gz
rm -f "$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected_brain.nii.gz
rm -f "$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected_brain_mask.nii.gz
rm -f "$participantID"_"$ses"_inv-2_MP2RAGE_N4corrected_brain_mask_ero.nii.gz 
