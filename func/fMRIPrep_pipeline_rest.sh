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
