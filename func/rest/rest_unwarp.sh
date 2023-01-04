#!/bin/bash
# LT Strike
# Requires FSL
# Requires opposite phase encoded bold scans, myacqparams.txt (specifies phase encoding direction & readout time)
# Usage: rest_unwarp.sh [participant_id]

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a participant_id'
    exit 0
fi

# Local (Neurodesk https://www.neurodesk.org/)
# Lauch through GUI: /Neurodesk/Functional Imaging/fsl or terminal: ml fsl
ml fsl
bids_dir=/neurodesktop-storage/qtab_bids
output_dir=/neurodesktop-storage/qtab_bids/derivatives/rest
code_dir=/neurodesktop-storage/GitHub/pre-processing/func/rest

participantID="$*"
ses="ses-01"

# Organise the data
mkdir -p ${output_dir}/${participantID}
cp -p ${bids_dir}/${participantID}/"$ses"/func/*rest* ${output_dir}/${participantID}

# Could remove the first 10 volumes to allow the magnatization to stablize to a steady state
# However, I think the scanner obtains dummy scans prior to actual scan. Can check data & MRIQC report to be sure
# fslroi ${participantID}_"$ses"_task-rest_dir-AP_bold.nii.gz ${participantID}_"$ses"_task-rest_dir-AP_bold_trimmed.nii.gz 10 317
# fslroi ${participantID}_"$ses"_task-rest_dir-PA_bold.nii.gz ${participantID}_"$ses"_task-rest_dir-PA_bold_trimmed.nii.gz 10 317

# topup
cd ${output_dir}/${participantID} 
fslroi ${participantID}_"$ses"_task-rest_dir-AP_bold.nii.gz AP 0 1
fslroi ${participantID}_"$ses"_task-rest_dir-PA_bold.nii.gz PA 0 1
fslmerge -t AP_PA.nii.gz AP.nii.gz PA.nii.gz
topup --imain=AP_PA --datain=${code_dir}/myacqparams.txt --config=b02b0.cnf --out=topup_AP_PA --iout=topup_AP_PA_iout --fout=topup_AP_PA_fout

# applytopup
applytopup --imain=${participantID}_"$ses"_task-rest_dir-AP_bold.nii.gz --inindex=1 --method=jac --datain=${code_dir}/myacqparams.txt --topup=topup_AP_PA --out=${participantID}_"$ses"_task-rest_dir-AP_bold_distcor --verbose
applytopup --imain=${participantID}_"$ses"_task-rest_dir-PA_bold.nii.gz --inindex=2 --method=jac --datain=${code_dir}/myacqparams.txt --topup=topup_AP_PA --out=${participantID}_"$ses"_task-rest_dir-PA_bold_distcor --verbose
fslmerge -t ${participantID}_"$ses"_task-rest_bold_distcor ${participantID}_"$ses"_task-rest_dir-AP_bold_distcor ${participantID}_"$ses"_task-rest_dir-PA_bold_distcor 

# Cleanup
rm -f ${output_dir}/${participantID}/AP.nii.gz
rm -f ${output_dir}/${participantID}/AP_PA.nii.gz
rm -f ${output_dir}/${participantID}/AP_PA.topup_log
rm -f ${output_dir}/${participantID}/PA.nii.gz
rm -f ${output_dir}/${participantID}/${participantID}_"$ses"_task-rest_dir-AP_bold.json
rm -f ${output_dir}/${participantID}/${participantID}_"$ses"_task-rest_dir-AP_bold.nii.gz
rm -f ${output_dir}/${participantID}/${participantID}_"$ses"_task-rest_dir-PA_bold.json
rm -f ${output_dir}/${participantID}/${participantID}_"$ses"_task-rest_dir-PA_bold.nii.gz
rm -f ${output_dir}/${participantID}/topup_AP_PA_fieldcoef.nii.gz
rm -f ${output_dir}/${participantID}/topup_AP_PA_fout.nii.gz
rm -f ${output_dir}/${participantID}/topup_AP_PA_iout.nii.gz
rm -f ${output_dir}/${participantID}/topup_AP_PA_movpar.txt

echo "Participant "$participantID" is finished"
