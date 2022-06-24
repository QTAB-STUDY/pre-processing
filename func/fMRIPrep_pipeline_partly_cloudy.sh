#!/bin/bash
# LT Strike
# Requires fMRIPrep & FreeSurfer
# Requires T1w (skull-stripped MP2RAGE uniform image renamed as T1w), bold, field maps (optional - not currently working)

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a participant_id'
    exit 0
fi

participantID="$*"
ses="ses-02"
echo Now running "$participantID"

## Local (Neurodesk https://www.neurodesk.org/)
# Lauch through GUI: /Neurodesk/Functional Imaging/fmriprep or terminal: ml fmriprep/21.0.1
# Make sure to include a link to the FreeSurfer licence file in the fMRIPrep call
ml fmriprep/21.0.1
data_dir=/neurodesktop-storage/qtab_bids
t1w_dir=/neurodesktop-storage/qtab_bids/derivatives/MP2RAGE_preprocessing
bids_dir=/neurodesktop-storage/qtab_analysis/fMRIPrep/bids
output_dir=/neurodesktop-storage/qtab_analysis/fMRIPrep/output
license_dir=/neurodesktop-storage/GitHub/pre-processing/anat
mem_mb="8000"
num_threads="2"


## Local BIDS directory setup (initial run only)
# mkdir -p "$bids_dir"
# mkdir -p "$output_dir"
# cp "$data_dir"/dataset_description.json "$bids_dir"
# cp "$data_dir"/README "$bids_dir"
# cp "$data_dir"/participants* "$bids_dir"

# Organise the data (bold, t1w, field maps)
mkdir -p "$bids_dir"/"$participantID"/"$ses"/func/
mkdir -p "$bids_dir"/"$participantID"/"$ses"/anat/
cp "$data_dir"/"$participantID"/"$ses"/func/"$participantID"_"$ses"_task-partlycloudy* "$bids_dir"/"$participantID"/"$ses"/func/
cp "$data_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_UNIT1.json "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_T1w.json
cp "$t1w_dir"/"$participantID"/"$participantID"_"$ses"_UNIT1_brain.nii.gz "$bids_dir"/"$participantID"/"$ses"/anat/"$participantID"_"$ses"_T1w.nii.gz
cp -r "$data_dir"/"$participantID"/"$ses"/fmap "$bids_dir"/"$participantID"/"$ses"/

# Run fMRIPrep
fmriprep "$bids_dir"/ "$output_dir"/ participant --participant_label "$participantID" \
	--skull-strip-t1w skip --fs-license-file "$license_dir"/.license -w /tmp/ \
	--mem "$mem_mb" --nprocs "$num_threads" \
	--ignore fieldmaps

echo "$participantID" is complete
