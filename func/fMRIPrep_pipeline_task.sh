#!/bin/bash
# LT Strike
# Work-in-Progress pipeline for the QTAB dataset (https://doi.org/10.18112/openneuro.ds004146.v1.0.2)
# Requires fMRIPrep & FreeSurfer
# Requires T1w (skull-stripped MP2RAGE UNIT1 renamed as T1w), bold, field maps (optional)
# Usage: fMRIPrep_pipeline_task.sh [participant_id]

# To Do:
# Look at paediatric MNI template 
# Susceptibility Distortion Correction (SDC) - field maps or field map less estimation (--use-syn-sdc)
# Field maps require metadata field in field map json: "IntendedFor":["ses-02/func/participant_id_ses-02_task-partlycloudy_bold.nii.gz"]

module load singularity/3.7.1

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a participant_id'
    exit 0
fi

# Neurodesk Singularity Containers
# https://www.neurodesk.org/docs/neurocontainers/singularity
# fmriprep_21.0.1_20220329

participantID="$*"
ses="ses-02"
container_dir=/working/lab_sarahme/lachlanS/containers
license_dir=/mnt/backedup/home/lachlanS/bin/qtab/sMRI/FreeSurfer
mem_mb="16000"
num_threads="4"

echo Now running "$participantID"

# Rename the masked UNIT1 scan as T1w
cp "$bids_dir"/derivatives/freesurfer/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_UNIT1-masked.nii.gz "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_T1w.nii.gz
cp "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_UNIT1.json "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_T1w.json

singularity run --cleanenv \
    --bind /working/lab_sarahme/lachlanS/qtab_data_task:/data \
    --bind /working/lab_sarahme/lachlanS/qtab_analysis/fMRIPrep:/output \
    "$container_dir"/freesurfer_7.3.2_20220812.simg \
    /data/ /output/ \
    participant --participant_label "$participantID" \
	--fs-license-file "$license_dir"/FreeSurfer_license \
	--mem "$mem_mb" --nprocs "$num_threads" \
	-t partlycloudy --skip_bids_validation 
#	--output-spaces MNIPediatricAsym:res-native:cohort-5 \
#	--use-syn-sdc

echo "$participantID" is complete
