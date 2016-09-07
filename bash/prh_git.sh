#!/bin/bash
dir="$HOME/src_prh"
ResDir="$dir/Research"
FitDir="$dir/FitUtil"
IgorDir="$dir/IgorUtil"

git clone --progress -v https://github.com/prheenan/Research "$ResDir"
git clone --progress -v https://github.com/prheenan/BioModel "$FitDir"
git clone --progress -v https://github.com/prheenan/IgorUtil "$IgorDir"

# configure ids; defaults to just us
function Ids
{
	current=`pwd`
	cd "$1"
	git config --local user.email "patrick.heenan@colorado.edu"
	git config --local user.name "patrick heenan"
	cd "$current"
} 
Ids "$ResDir"
Ids "$FitDir"
Ids "$IgorDir"
