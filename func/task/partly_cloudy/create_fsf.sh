#!/bin/bash

# LT Strike
# Code for the Partly Cloudy task in the QTAB dataset
# This analysis pipeline is a work-in-progress - there are likely errors, bugs etc.

code_dir=/home/user/Desktop/neurodesktop-storage/github/func/task/partly_cloudy

# Create a .fsf file for each participant, based on a template
# Find & replace QTABID in the template with the participant_id
while read participant_id; do
    cd "$code_dir" ||
    echo "$participant_id"
    cat "$code_dir"/template_full_analysis.fsf | sed s/QTABID/"$participant_id"/g > "$code_dir"/"$participant_id"_full_analysis.fsf
    done < "$code_dir"/participant_id.txt

# Run preprocessing and statistics
# Local (Neurodesktop)
# ml fsl/6.0.5.1 # needs to match the fsl directory given in template_preprocessing.fsf

# feat "$participant_id".fsf
# Note: Pay special attention to the registration between the field map and the structural scan
# A modification to the epi_reg script may be needed if registration fails
# Specifically these lines: 

# Orig
# register fmap to structural image
# $FSLDIR/bin/flirt -in ${fmapmagbrain} -ref ${vrefbrain} -dof 6 -omat ${vout}_fieldmap2str_init.mat
# $FSLDIR/bin/flirt -in ${fmapmaghead} -ref ${vrefhead} -dof 6 -init ${vout}_fieldmap2str_init.mat -omat ${vout}_fieldmap2str.mat -out ${vout}_fieldmap2str -nosearch

# Modified (two lines of code above replaced with)
# register fmap to structural image
# $FSLDIR/bin/flirt -in ${fmapmagbrain} -ref ${vrefbrain} -dof 6 -omat ${vout}_fieldmap2str.mat -out ${vout}_fieldmap2str

# see https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=FSL;360f54df.1910

