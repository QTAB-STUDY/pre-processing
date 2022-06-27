#!/bin/bash
# LT Strike
# Work-in-Progress pipeline for the QTAB dataset (https://doi.org/10.18112/openneuro.ds004146.v1.0.2)
# Requires fMRIPrep & FreeSurfer
# Requires T1w (skull-stripped MP2RAGE uniform image renamed as T1w), bold, field maps (optional - not currently working)
# Uses Paediatric MNI template cohort 5: 10 - 14 years, early to advanced puberty
# Susceptibility Distortion Correction (SDC) - field maps or field map less estimation (--use-syn-sdc)
# Field maps require metadata field in json:
# "IntendedFor":["ses-02/func/participant_id_ses-02_task-partlycloudy_bold.nii.gz"]
# Field map correction doesn't appear to be working - seems to over-correct?
# Usage: fMRIPrep_pipeline_partly_cloudy.sh [participant_id]

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a participant_id'
    exit 0
fi

## Local (Neurodesk https://www.neurodesk.org/)
# Lauch through GUI: /Neurodesk/Functional Imaging/fmriprep or terminal: ml fmriprep/21.0.1
# Make sure to include a link to the FreeSurfer licence file in the fMRIPrep call
ml fmriprep/21.0.1 

participantID="$*"
ses="ses-02"
mem_mb="12000"
num_threads="2"
bids_dir=/neurodesktop-storage/qtab_bids
t1w_dir=/neurodesktop-storage/qtab_bids/derivatives/MP2RAGE_preprocessing
output_dir=/neurodesktop-storage/qtab_analysis/fMRIPrep
license_dir=/neurodesktop-storage/GitHub/pre-processing/anat
echo Now running "$participantID"

# Rename the skull-stripped MP2RAGE UNIT1 scan as T1w
cp "$t1w_dir"/"$participantID"/"$participantID"_"$ses"_UNIT1_brain.nii.gz "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_T1w.nii.gz
cp "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_inv-2_MP2RAGE.json "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_T1w.json

# Run fMRIPrep (SDC - field map-less estimation rather than field maps)
fmriprep "$bids_dir"/ "$output_dir"/ participant --participant_label "$participantID" \
	--skull-strip-t1w skip --fs-license-file "$license_dir"/.license -w /tmp/ \
	--mem "$mem_mb" --nprocs "$num_threads" \
	-t partlycloudy --skip_bids_validation --output-spaces MNIPediatricAsym:res-native:cohort-5 \
	--use-syn-sdc

echo "$participantID" is complete
