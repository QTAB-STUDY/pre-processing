#!/bin/bash
# LT Strike
# Requires fMRIPrep & FreeSurfer
# Requires T1w (skull-stripped MP2RAGE uniform image renamed as T1w), bold, field maps

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a participant_id'
    exit 0
fi

# Local Run (Neurodesk https://www.neurodesk.org/)
# Lauch through GUI: /Neurodesk/Functional Imaging/fmriprep or terminal: ml fmriprep/21.0.1
# Make sure to include a link to the FreeSurfer licence file in the fMRIPrep call
ml fmriprep/21.0.1 

participantID="$*"
ses="ses-02"
mem_mb="8000"
num_threads="2"
bids_dir=/neurodesktop-storage/qtab_bids
t1w_dir=/neurodesktop-storage/qtab_bids/derivatives/MP2RAGE_preprocessing
output_dir=/neurodesktop-storage/qtab_analysis/fMRIPrep
license_dir=/neurodesktop-storage/GitHub/pre-processing/anat
echo Now running "$participantID"

# Rename the skull-stripped MP2RAGE UNIT1 scan as T1w
cp "$t1w_dir"/"$participantID"/"$participantID"_"$ses"_UNIT1_brain.nii.gz "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_T1w.nii.gz
cp "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_inv-2_MP2RAGE.json "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_T1w.json

# Run fMRIPrep
fmriprep "$bids_dir"/ "$output_dir"/ participant --participant_label "$participantID" \
	--skull-strip-t1w skip --fs-license-file "$license_dir"/.license -w /tmp/ \
	--mem "$mem_mb" --nprocs "$num_threads" \
	-t partlycloudy --skip_bids_validation

echo "$participantID" is complete
