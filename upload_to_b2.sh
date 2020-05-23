#!/bin/bash

##############
# Script to upload files from local to b2 bucket using docker image:
# https://hub.docker.com/repository/docker/hipposareevil/b2
#
# Variables:
# BUCKET_NAME    - Name of b2 bucket
# KEY_ID         - b2 application key ID
# APPLICATION_ID - b2 application ID
# ROOT_DIRECTORY - Directory with files to upload
# STAGING_AREA   - Temporary directory where files are copied and renamed.
#   This is due to b2 failing on files with space " ".  So spaces
#   are changed to underscores "_" for the upload.
#
##############

#########
# Set up variables
# 
#########
initialize_variables() {
    jq_exists=$(which jq)
    if [$? -ne 0]; then
        log "jq program must be installed."
        exit 1
    fi

    default_bucket="BUCKET NAME"
    default_key="DEFAULT KEY"
    default_appliation="DEFAULT APPLICATION ID"
    default_root_directory=$HOME
    default_staging="/tmp/photos"

    export b2_bucket_name=${BUCKET_NAME:-${default_bucket}}
    export b2_key_id=${KEY_ID:-${default_key}}
    export b2_application_id=${APPLICATION_ID:-${default_appliation}}

    export root_directory=${ROOT_DIRECTORY:-${default_root_directory}}
    if [ ! -d "$root_directory" ]; then
        log "Root directory '$root_directory' does not exist."
        exit 1
    fi

    export staging_directory=${STAGING_AREA:-${default_staging}}
    mkdir -p $staging_directory
}

#########
# Log to stdout.
# Update to file location if desired.
# 
######### 
log() {
    echo "$@"
}

#######
# b2 function
#
# Uses the ${staging_directory} as scratch root.
######
b2() {
    docker run --rm -v $staging_directory:/scratch \
	   -e KEY_ID=${b2_key_id} \
	   -e APPLICATION_KEY=${b2_application_id} \
	   hipposareevil/b2 "$@"
}


#########
# Perform backup on specified directory
#########
do_backup() {
    log "Getting remote file list from b2 '${b2_bucket_name}'"

    # Get all files
    # 'tail -n +2' skips the first line
    files=$(b2 list_file_names ${b2_bucket_name} | tail -n +2 | jq -r  ".files[].fileName")
    num_files=$(echo "${files}" | wc -l)

    log "Number of files in remote b2: ${num_files}"
    log "Backing up local directory '${root_directory}/*'"

    # counter of number files
    num_copied_files=0

    # Go through all files in directory, ignoring those with 'part' in them
    # as nextcloud uses that for in process files
    for fq_file in ${root_directory}/*
    do
        if [[ -f $fq_file ]]; then
            # file exists for reals
            file=$(basename "$fq_file")
            # replace " " with "_"
            converted_name=$(log "$file"| sed 's/ /_/g')

            log "Looking at local '$file'.  Remote version is '$converted_name'"

            if [[ "$file" == *"part"* ]]; then
                log "Skipping 'part' file"
                continue
            fi

            if [[ "$files" == *"$converted_name"* ]]; then
                log "'${file}' already exists in b2. Moving on."
            else
                log "Upload file: '${converted_name}'"
                cp "${fq_file}" "${staging_directory}/${converted_name}"

                result=$(b2 upload_file "${b2_bucket_name}" "${converted_name}" "${converted_name}")
                if [ $? -eq 0 ]; then
                    log "Uploaded."
                    num_copied_files=$((num_copied_files + 1))
                else
                    log "Unable to upload ${converted_name}"
                    log "${result}"
                fi
                rm "${staging_directory}/${converted_name}"
            fi
        fi
    done

    log ""
    log ""
    log "Backed up ${num_copied_files} files to b2"
}


########
# Main
#
########
main() {
    initialize_variables

    do_backup
}


main "$@"
