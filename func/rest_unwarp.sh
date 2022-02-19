#!/bin/bash
#PBS -A UQ-QBI
#PBS -N pbsS1
#PBS -l select=1:ncpus=1:mem=6GB
#PBS -l walltime=01:00:00
#PBS -J 1-166
module load singularity

## rs-fMRI pre-preprocessing
ANALYSIS_DIR=/90days/user/qtab_analysis/rsfMRI
CODE_DIR=/home/user/bin/qtab/rsfMRI/conn
BIDS_DIR=/QRISdata/Q1319/data/mri/BIDS_sorted
CONTAINER_DIR=/90days/user/containers
OUTPUT_DIR=/RDS/Q0292/QTAB/rs_fMRI/1_pre_preprocessed/

participants=`cat ${CODE_DIR}/S1_participants.txt`
participantsArray=($participants)
imgID=`echo ${participantsArray[${PBS_ARRAY_INDEX}]}`

subj=${imgID/_*}
mkdir -p ${ANALYSIS_DIR}/${imgID}
cd ${ANALYSIS_DIR}/${imgID}
cp -p ${BIDS_DIR}/sub-${subj}/ses-02/func/*rest*.nii.gz .
singularity exec ${CONTAINER_DIR}/debian_9.4_mrtrix3_fsl5.simg fslroi sub-${subj}_ses-02_task-rest_AP_bold.nii.gz AP_317 10 317 # Remove first 10 vols - may not be necessary
singularity exec ${CONTAINER_DIR}/debian_9.4_mrtrix3_fsl5.simg fslroi sub-${subj}_ses-02_task-rest_PA_bold.nii.gz PA_317 10 317 # Remove first 10 vols - may not be necessary
singularity exec ${CONTAINER_DIR}/debian_9.4_mrtrix3_fsl5.simg fslroi AP_317.nii.gz AP 0 1
singularity exec ${CONTAINER_DIR}/debian_9.4_mrtrix3_fsl5.simg fslroi PA_317.nii.gz PA 0 1
singularity exec ${CONTAINER_DIR}/debian_9.4_mrtrix3_fsl5.simg fslmerge -t AP_PA.nii.gz AP.nii.gz PA.nii.gz
singularity exec ${CONTAINER_DIR}/debian_9.4_mrtrix3_fsl5.simg topup --imain=AP_PA --datain=${CODE_DIR}/myacqparams.txt --config=b02b0.cnf --out=topup_AP_PA --iout=topup_AP_PA_iout --fout=topup_AP_PA_fout
singularity exec ${CONTAINER_DIR}/debian_9.4_mrtrix3_fsl5.simg applytopup --imain=AP_317.nii.gz --inindex=1 --method=jac --datain=${CODE_DIR}/myacqparams.txt --topup=topup_AP_PA --out=${imgID}_runAP --verbose
singularity exec ${CONTAINER_DIR}/debian_9.4_mrtrix3_fsl5.simg applytopup --imain=PA_317.nii.gz --inindex=2 --method=jac --datain=${CODE_DIR}/myacqparams.txt --topup=topup_AP_PA --out=${imgID}_runPA --verbose

mkdir ${OUTPUT_DIR}/${imgID}
cp -p ${ANALYSIS_DIR}/${imgID}/*run* ${OUTPUT_DIR}/${imgID}
rm -rf ${ANALYSIS_DIR}/${imgID}
