#!/bin/bash

# FreeSurfer run using skull stripped MP2RAGE UNITI as input
recon-all -autorecon1 -noskullstrip -hires -s "$participantID"_"$ses" -i "$participantID"_"$ses"_UNIT1_brain.nii.gz
cd "$SUBJECTS_DIR"/"$participantID"_"$ses"/mri
ln -s T1.mgz brainmask.auto.mgz
ln -s brainmask.auto.mgz brainmask.mgz
recon-all -autrecon2 -autorecon3 -s "$participantID"_"$ses" -hires
