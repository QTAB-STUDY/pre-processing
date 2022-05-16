#!/bin/bash

# LT Strike
# Code for the Partly Cloudy task in the QTAB dataset
# This analysis pipeline is a work-in-progress - there are likely errors, bugs etc.

code_dir=/home/user/Desktop/neurodesktop-storage/github/func/task/partly_cloudy

# Create a .fsf file for each participant, based on a template
while read participant_id; do
    cd "$code_dir" ||
    echo "$participant_id"
    cat "$code_dir"/template_preprocessing.fsf | sed s/QTABID/"$participant_id"/ > "$code_dir"/"$participant_id".fsf
    done < "$code_dir"/participant_id_preprocessing.txt

# Run preprocessing
# Issues with mp2rage registration ....
# feat "$participant_id".fsf
