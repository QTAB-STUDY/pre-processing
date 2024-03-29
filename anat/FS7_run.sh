#!/bin/bash
# LT Strike
# Requires FreeSurfer
# Uses a brain extracted MP2RAGE as T1w input (FreeSurfer can have difficulty with UNIT1 due to excessive background noise)
# Usage: FS7_run.sh [participant_id]

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a participant_id'
    exit 0
fi

## Local (Neurodesk https://www.neurodesk.org/)
# Lauch through GUI - Neurodesk -> Image Segmentation -> Freesurfer -> Freesurfer 7.2.0
source /opt/freesurfer-7.2.0/SetUpFreeSurfer.sh
export SUBJECTS_DIR=/neurodesktop-storage/freesurfer-output
export FS_LICENSE=/neurodesktop-storage/github/anat/.license

data_dir=/neurodesktop-storage/qtab_bids/derivatives/MP2RAGE_preprocessing
ses=ses-01
participantID="$@"

recon-all -autorecon1 -noskullstrip -hires -s "$participantID"_"$ses" -i "$data_dir"/"$participantID"/"$participantID"_"$ses"_UNIT1_brain.nii.gz
cd "$SUBJECTS_DIR"/"$participantID"_"$ses"/mri
ln -s T1.mgz brainmask.auto.mgz
ln -s brainmask.auto.mgz brainmask.mgz
recon-all -autorecon2 -autorecon3 -s "$participantID"_"$ses" -hires
