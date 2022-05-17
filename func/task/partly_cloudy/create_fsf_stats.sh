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
    cat "$code_dir"/template_stats.fsf | sed s/QTABID/"$participant_id"/g > "$code_dir"/"$participant_id"_stats.fsf
    done < "$code_dir"/participant_id_preprocessing.txt

# Run preprocessing
# Local (Neurodesktop)
# ml fsl/6.0.5.1 # needs to match the fsl directory given in template_preprocessing.fsf

# feat "$participant_id_stats".fsf
