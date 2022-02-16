#!/bin/bash

# --------------------------------------
# Pre-processing steps for qtab dMRI
# Authors: Lachlan T Strike, Katie L McMahon
# Uses nifti data
# --------------------------------------

# NeuroDesk
ml mrtrix3/3.0.3

if [ -z "$1" ]
then
    echo "Usage: $0 participantID"
    exit 127
fi

participantID="$1"
ses=ses-01
data_dir=/home/user/Desktop/neurodesktop-storage/qtab_analysis/dMRI/

echo "Now running pre-processing: $subj"
cd "$data_dir"/"$participantID"

mrconvert -json_import "$participantID"_"$ses"_acq-AP_run-01_dwi.json -fslgrad "$participantID"_"$ses"_acq-AP_run-01_dwi.bvec \
"$participantID"_"$ses"_acq-AP_run-01_dwi.bval  "$participantID"_"$ses"_acq-AP_run-01_dwi.nii.gz dwi_ap1.mif
mrconvert -json_import "$participantID"_"$ses"_acq-AP_run-02_dwi.json -fslgrad "$participantID"_"$ses"_acq-AP_run-02_dwi.bvec \
"$participantID"_"$ses"_acq-AP_run-02_dwi.bval "$participantID"_"$ses"_acq-AP_run-02_dwi.nii.gz dwi_ap2.mif
mrconvert -json_import "$participantID"_"$ses"_acq-PA_run-01_dwi.json -fslgrad "$participantID"_"$ses"_acq-PA_run-01_dwi.bvec \
"$participantID"_"$ses"_acq-PA_run-01_dwi.bval "$participantID"_"$ses"_acq-PA_run-01_dwi.nii.gz dwi_pa1.mif
mrconvert -json_import "$participantID"_"$ses"_acq-PA_run-02_dwi.json -fslgrad "$participantID"_"$ses"_acq-PA_run-02_dwi.bvec \
"$participantID"_"$ses"_acq-PA_run-02_dwi.bval "$participantID"_"$ses"_acq-PA_run-02_dwi.nii.gz dwi_pa2.mif

dwidenoise dwi_pa1.mif den_pa1.mif
dwidenoise dwi_ap1.mif den_ap1.mif
dwidenoise dwi_ap2.mif den_ap2.mif
dwidenoise dwi_pa2.mif den_pa2.mif

mrcat den_ap1.mif den_ap2.mif den_pa1.mif den_pa2.mif dwi_denoised.mif -axis 3

dwifslpreproc dwi_denoised.mif dwi_denoised_preproc.mif -rpe_header -eddyqc_all qc -eddy_options " --repol"
# --repol - replace outlier slices with Gaussian predictions
# --mporder - not included, but could look at (slice-to-volume motion correction)
# dwipreproc in earlier MRtrix releases