#!/bin/bash
# courtesy of: http://redsymbol.net/articles/unofficial-bash-strict-mode/
# (helps with debugging)
# set -e: immediately exit if we find a non zero
# set -u: undefined references cause errors
# set -o: single error causes full pipeline failure.
set -euo pipefail
IFS=$'\n\t'
# datestring, used in many different places...
dateStr=`date +%Y-%m-%d:%H:%M:%S`

# Description:
# utilities for git functons 
# Arguments:
#### Arg 1: Description

# Returns:
dir="$HOME/src_prh"
ResDir="$dir/Research"
FitDir="$dir/FitUtil"
IgorDir="$dir/IgorUtil"


# configure ids; defaults to just us
function Ids
{
	current=`pwd`
	cd "$1"
	git config --local user.email "patrick.heenan@colorado.edu"
	git config --local user.name "patrick heenan"
	cd "$current"
} 

setup_ids()
{
    Ids "$ResDir"
    Ids "$FitDir"
    Ids "$IgorDir"
}

git_setup()
{
    git clone --progress -v https://github.com/prheenan/Research "$ResDir"
    git clone --progress -v https://github.com/prheenan/BioModel "$FitDir"
    git clone --progress -v https://github.com/prheenan/IgorUtil "$IgorDir"
    setup_ids
}

git_act()
{
    git $@ "$ResDir"
    git $@ "$FitDir"
    git $@ "$IgorDir"

}

# XXX these dont quite work...
git_pull()
{
    git_act pull
}

git_push()
{
    git_act push
}

setup_ids || true
git_setup
