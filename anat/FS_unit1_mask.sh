#!/bin/bash

# Pass this script to Singularity
source /opt/freesurfer-*/SetUpFreeSurfer.sh
export SUBJECTS_DIR=/subjects
export FS_LICENSE=/containers/.license
export OMP_NUM_THREADS=4

bidsID="$*"
ss="ses-01"
echo "Now running participant $bidsID"

run_samseg --input "$bidsID"_"$ss"_inv-2_MP2RAGE.nii.gz --output /subjects/"$bidsID"_samseg --threads 4
mri_mask "$bidsID"_"$ss"_UNIT1.nii.gz /subjects/"$bidsID"_samseg/seg.mgz "$bidsID"_"$ss"_UNIT1_masked.nii.gz

