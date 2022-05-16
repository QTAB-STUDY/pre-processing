#!/bin/bash
# LT Strike
# Generate field maps to use in FEAT (prestats) to unwarp the task fMRI images (work in progress)
# Tasks are acquired in AP phase encoding direction [j-] (AP is [j-], PA is [j])
# fmap_acqparams.txt - set up for 4 x AP, 4 x PA volumes. Readout time is 0.0533986 (from json sidecar)
# Pieced together from
# https://lcni.uoregon.edu/kb-articles/kb-0003
# https://github.com/Washington-University/HCPpipelines/blob/master/global/scripts/TopupPreprocessingAll.sh

# Local (Neurodesktop)
ml fsl/6.0.4
data_dir=/neurodesktop-storage/qtab_bids
code_dir=/home/user/Desktop/neurodesktop-storage/github/pre-processing/func/task_fMRI
output_dir="$data_dir"/derivatives/fmap

participantID="$@"
EchoSpacing=0.000599984 # Based on the AP/PA epi (not task) scans
txtfname="$output_dir"/"$participantID"/fmap_acqparams.txt

mkdir -p "$output_dir"/"$participantID"
cp "$data_dir"/"$participantID"/ses-02/fmap/"$participantID"_ses-02_dir-AP_epi.nii.gz "$output_dir"/"$participantID"
cp "$data_dir"/"$participantID"/ses-02/fmap/"$participantID"_ses-02_dir-PA_epi.nii.gz "$output_dir"/"$participantID"
cp "$code_dir"/fmap_acqparams.txt "$output_dir"/"$participantID"

cd "$output_dir"/"$participantID"
fslreorient2std "$participantID"_ses-02_dir-AP_epi.nii.gz fmap_AP
fslreorient2std "$participantID"_ses-02_dir-PA_epi.nii.gz fmap_PA

fslmerge -t AP_PA.nii.gz fmap_AP.nii.gz fmap_PA.nii.gz
topup --imain="$output_dir"/"$participantID"/AP_PA.nii.gz --datain="$txtfname" --config=b02b0.cnf --out="$output_dir"/"$participantID"/Coefficents --iout="$output_dir"/"$participantID"/Magnitudes --fout="$output_dir"/"$participantID"/TopupField

# Calculate Equivalent Field Map
fslmaths TopupField -mul 6.283 TopupField_rads # Convert from Hz to rad/s [scale by 2 * pi]
fslmaths "$output_dir"/"$participantID"/Magnitudes -Tmean "$output_dir"/"$participantID"/Magnitude
bet "$output_dir"/"$participantID"/Magnitude "$output_dir"/"$participantID"/Magnitude_brain -f 0.5 -m #Brain extract the magnitude image
rm -rf sub-* 
