#!/bin/bash

# --------------------------------------
# Pre-processing steps for qtab dMRI
# Authors: Lachlan T Strike, Katie L McMahon
# Used to extract quality checking metrics (absolute motion, relative motion, number of outlier slices) in the QTAB dataset
# Uses dicom data
# --------------------------------------

# NeuroDesk
ml mrtrix3/3.0.3

if [ -z "$1" ]
then
    echo "Usage: $0 participantID"
    exit 127
fi

participantID="$1"
data_dir=/home/user/Desktop/neurodesktop-storage/qtab_analysis/dMRI

echo "Now running pre-processing: $subj"
cd "$data_dir"/"$participantID"

DIFF_AP1="A-P_BLOCK_1"
DIFF_AP2="A-P_BLOCK_2"
DIFF_PA1="P-A_BLOCK_1"
DIFF_PA2="P-A_BLOCK_2"

mrconvert A-P_BLOCK_1 dwi_ap1.mif
mrconvert A-P_BLOCK_2 dwi_ap2.mif
mrconvert P-A_BLOCK_1 dwi_pa1.mif
mrconvert P-A_BLOCK_2 dwi_pa2.mif

dwidenoise dwi_pa1.mif den_pa1.mif
dwidenoise dwi_ap1.mif den_ap1.mif
dwidenoise dwi_ap2.mif den_ap2.mif
dwidenoise dwi_pa2.mif den_pa2.mif

mrcat den_ap1.mif den_ap2.mif den_pa1.mif den_pa2.mif dwi_denoised.mif -axis 3

rm -rf "$data_dir"/"$participantID"/A-P_BLOCK_1
rm -rf "$data_dir"/"$participantID"/P-A_BLOCK_1
rm -rf "$data_dir"/"$participantID"/A-P_BLOCK_2
rm -rf "$data_dir"/"$participantID"/P-A_BLOCK_2
rm -f "$data_dir"/"$participantID"/dwi_ap1.mif
rm -f "$data_dir"/"$participantID"/dwi_ap2.mif
rm -f "$data_dir"/"$participantID"/dwi_pa1.mif
rm -f "$data_dir"/"$participantID"/dwi_pa2.mif
rm -f "$data_dir"/"$participantID"/den_ap1.mif
rm -f "$data_dir"/"$participantID"/den_ap2.mif
rm -f "$data_dir"/"$participantID"/den_pa1.mif
rm -f "$data_dir"/"$participantID"/den_pa2.mif

dwifslpreproc dwi_denoised.mif dwi_denoised_preproc.mif -rpe_header -eddyqc_all qc -eddy_options " --repol"
# --repol - replace outlier slices with Gaussian predictions
# --mporder - not included, but could look at (slice-to-volume motion correction)