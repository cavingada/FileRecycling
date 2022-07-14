#!/bin/bash
# junk.sh
# Author @  Cavin Gada


# basename help (credit) from: https://unix.stackexchange.com/questions/452669/how-to-get-the-filename-of-a-symlink-destination-in-a-shell-script
function show_usage {
    cat << EOF
Usage: $(basename "$0") [-hlp] [list of files]
    -h: Display help.
    -l: List junked files.
    -p: Purge all files.
    [list of files] with no other arguments to junk those files.
EOF
}

first_iteration="true"
last_command="h"
flag_exists="false"
valid_flag=4 # if valid flag is 1 - execute h, if 2 - execute l, if 3-execute p. if 0, too many options

while getopts ":hlp" options; do

    if [[ $first_iteration == "true" ]]; then
        last_command="${options}"
    else 
        if [[ "${options}" != "$last_command" ]]; then
            valid_flag=0
        fi
    fi

  case "${options}" in                   
    h)
        if [[ $valid_flag -ne 0 ]]; then
            valid_flag=1
            flag_exists="true"
        fi
        ;;
    l)
        if [[ $valid_flag -ne 0 ]]; then
            valid_flag=2
            flag_exists="true"
        fi
        ;;
    p)
        if [[ $valid_flag -ne 0 ]]; then
            valid_flag=3
            flag_exists="true"
        fi
        ;;
    *)
        option=${OPTARG}   
        echo "Error: Unknown option" "'-$option'."
        show_usage
        exit 1
        ;;
  esac
  first_iteration="false"
done

# if no command line arguments, show usage
if [[ $# -eq 0 ]]; then
    show_usage
    exit 0
fi

# if there are options and arguments entered, too many options entered
if [[ $OPTIND -lt $(($# + 1)) && $flag_exists == "true" ]]; then
    valid_flag=0
fi

readonly junk="/home/$(whoami)/.junk"

# if junk directory doesnt exist, make it. 
function make_directory {
    if [[ ! -d $junk ]]; then
        mkdir $junk
    fi
}

make_directory;

case "$valid_flag" in  
    0) 
        echo "Error: Too many options enabled."
        show_usage
        exit 1
        ;;                 
    1) # option H
        show_usage
        exit 0
        ;;
    2) # option L
        ls -lAF $junk
        exit 0
        ;;
    3) # option P
        rm -rf $junk        #delete the directory and all contents and recreate it. 
        make_directory;
        exit 0
        ;;
esac

# if only files are inputted in command line, then add the files
if [[ $flag_exists == "false" ]]; then
    for fileOrFolder in "$@"; do
        # if file exists, move it to junk
        if [[ -f "$fileOrFolder" || -d "$fileOrFolder" ]]; then
            mv $fileOrFolder $junk
        # otherwise, give a warning
        else
            echo "Warning: '$fileOrFolder' not found."
        fi
    done
fi
exit 0