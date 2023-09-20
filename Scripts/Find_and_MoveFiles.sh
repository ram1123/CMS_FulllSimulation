#!/bin/bash

# --------------------------------------------------------------
# Script for moving specific files from multiple directories
# to a target directory, while preserving the directory name.
# --------------------------------------------------------------


# Define the target directory where files will be moved
# Change this path as needed.
TARGET_DIR="/eos/user/r/rasharma/temp_nanoSetup/aTGC_Custom_nanoAOD_logs"

# List of directories to scan for files
# Update this list according to the directories you want to scan.
DIRS=("WmZToLmNujj_01j_aTGC_pTZ-150toInf_mWV-150to600"
      "WmZToLmNujj_01j_aTGC_pTZ-150toInf_mWV-600to800"
      "WmZToLmNujj_01j_aTGC_pTZ-150toInf_mWV-800toInf"
      "WpZToLpNujj_01j_aTGC_pTZ-150toInf_mWV-150to600"
      "WpZToLpNujj_01j_aTGC_pTZ-150toInf_mWV-600to800"
      "WpZToLpNujj_01j_aTGC_pTZ-150toInf_mWV-800toInf")

# Loop through each directory specified in DIRS
for dir in "${DIRS[@]}"; do

    # Create a corresponding subdirectory in the target directory
    # This preserves the original directory name.
    mkdir -p "${TARGET_DIR}/${dir}"

    # Use 'find' and 'grep' to locate files that do not contain "6134212"
    # Then loop over these files.
    find "${dir}" -type f -exec grep -L "6134212" {} + | while read -r file; do

        # Extract the filename from the full path
        filename=$(basename "$file")

        # Move the file to the corresponding subdirectory in the target directory
        mv "$file" "${TARGET_DIR}/${dir}/${filename}"
    done
done
