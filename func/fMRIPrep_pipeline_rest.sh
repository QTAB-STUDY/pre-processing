#!/bin/bash
# LT Strike
# Work-in-Progress pipeline for the QTAB dataset (https://doi.org/10.18112/openneuro.ds004146.v1.0.2)
# Requires fMRIPrep & FreeSurfer
# Requires T1w (MP2RAGE UNIT1 with background noise masked out), bold (unwarped prior to fMRIPrep)
# Usage: fMRIPrep_pipeline_rest.sh [participant_id]

# To Do:
# Look at paediatric MNI template

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a participant_id'
    exit 0
fi

# Neurodesk Singularity Containers
# https://www.neurodesk.org/docs/neurocontainers/singularity
# fmriprep_21.0.1_20220329

participantID="$*"
ses="ses-01"
bids_dir=/neurodesktop-storage/qtab_bids
rest_dir=/neurodesktop-storage/qtab_bids/derivatives/rest
t1w_dir=/neurodesktop-storage/qtab_bids/derivatives/MP2RAGE_preprocessing
output_dir=/neurodesktop-storage/qtab_analysis/fMRIPrep
license_dir=/neurodesktop-storage/GitHub/pre-processing/anat
mem_mb="8000"
num_threads="4"
echo Now running "$participantID"

# Run fMRIPrep
fmriprep "$bids_dir"/ "$output_dir"/ participant --participant_label "$participantID" \
        --fs-license-file "$license_dir"/.license -w /tmp/ \
        --mem "$mem_mb" --nprocs "$num_threads" -t rest

echo "$participantID" is complete






## Local (Neurodesk https://www.neurodesk.org/)
# Lauch through GUI: /Neurodesk/Functional Imaging/fmriprep or terminal: ml fmriprep/21.0.1
# Make sure to include a link to the FreeSurfer licence file in the fMRIPrep call
ml fmriprep/21.0.1

participantID="$*"
ses="ses-01"
bids_dir=/neurodesktop-storage/qtab_bids
rest_dir=/neurodesktop-storage/qtab_bids/derivatives/rest
t1w_dir=/neurodesktop-storage/qtab_bids/derivatives/MP2RAGE_preprocessing
output_dir=/neurodesktop-storage/qtab_analysis/fMRIPrep
license_dir=/neurodesktop-storage/GitHub/pre-processing/anat
mem_mb="6000"
num_threads="2"
echo Now running "$participantID"

# Rename the skull-stripped MP2RAGE UNIT1 scan as T1w
cp "$t1w_dir"/"$participantID"/"$participantID"_"$ses"_UNIT1_brain.nii.gz "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_T1w.nii.gz
cp "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_inv-2_MP2RAGE.json "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_T1w.json

# Use topup/applytop distortion corrected rest scans
mv "$bids_dir"/"$participantID"/"$ses"/func/"$participantID"_"$ses"_task-rest_dir-AP_bold.nii.gz "$bids_dir"/"$participantID"/"$ses"/func/"$participantID"_"$ses"_task-rest_dir-AP_bold_raw.nii.gz
mv "$bids_dir"/"$participantID"/"$ses"/func/"$participantID"_"$ses"_task-rest_dir-PA_bold.nii.gz "$bids_dir"/"$participantID"/"$ses"/func/"$participantID"_"$ses"_task-rest_dir-PA_bold_raw.nii.gz
cp "$rest_dir"/"$participantID"/"$participantID"_"$ses"_task-rest_dir-AP_bold_distcor.nii.gz "$bids_dir"/"$participantID"/"$ses"/func/"$participantID"_"$ses"_task-rest_dir-AP_bold.nii.gz
cp "$rest_dir"/"$participantID"/"$participantID"_"$ses"_task-rest_dir-PA_bold_distcor.nii.gz "$bids_dir"/"$participantID"/"$ses"/func/"$participantID"_"$ses"_task-rest_dir-PA_bold.nii.gz

# Run fMRIPrep
fmriprep "$bids_dir"/ "$output_dir"/ participant --participant_label "$participantID" \
	--skull-strip-t1w skip --fs-license-file "$license_dir"/.license -w /tmp/ \
	--mem "$mem_mb" --nprocs "$num_threads" -t rest

echo "$participantID" is complete
