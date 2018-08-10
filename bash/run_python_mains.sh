#!/bin/bash
# courtesy of: http://redsymbol.net/articles/unofficial-bash-strict-mode/
# (helps with debugging)
# set -e: immediately exit if we find a non zero
# set -u: undefined references cause errors
# set -o: single error causes full pipeline failure.
#set -euo pipefail
IFS=$'\n\t'
# datestring, used in many different places...
dateStr=`date +%Y-%m-%d:%H:%M:%S`

# Description:

# Arguments:
#### Arg 1: The input directory, based as --base to all the python files
#### Arg 2: if all pkl files in the input directory should be deleted 
#### Arg 3: A regex pattern; python likes matching this (using grep -ioP) are skipped. Optional
#### Arg 4: where the python files live. Should be a directory with folders, one folder per main

# Returns: Nothing, runs each python file, printing diagnostic information as it goes. 

input_dir="${1}"
delete_cache="${2:-0}"
skip_regex="${3:-}"
python_dir="${4:-../}"
# get the absolute input directory 
cd "$input_dir" > /dev/null
abs_input=$( pwd )
abs_input="${abs_input}/"
cd - > /dev/null
# remove the cache, if necessary
if [ $delete_cache -eq "1" ] 
	then
	echo "Deleting"
	find $input_dir -type f -name "*.pkl" | xargs rm 
fi
exit
files=$( find "$python_dir" -path "*/_*" -name "main*.py" -type f  )
for f in $files
    do
	dir=$( dirname "$f")
	file=$( basename "$f")
	cd "$dir"  > /dev/null
	# check if we have a regex 
	if [ ! -z "$skip_regex" ] 
		then
		grep_return=$( echo "$file" | grep -ioP $skip_regex )
		# check if it matches 
		echo "Regex $skip_regex used on $file, yielding [$grep_return]."
		if [ ! -z "$grep_return" ]
			then
			echo -e "\t ==== Skipping $file ====" 
			continue
		fi
	fi
	str_to_run="python $file --base $abs_input"
	echo -e "In $dir, running: \n$str_to_run \n"
	$( eval "$str_to_run" )
	# go back to the original directory
	cd -  > /dev/null
done

# run the analysis