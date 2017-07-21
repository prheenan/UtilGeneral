export PS1="$:"
home="$HOME/src_prh/GeneralUtil/bash/"
# where the profile is 
base="$home"
profile=".profile"
identikey="pahe3165"
# supposedly makes it infinite
export HISTSIZE="GOTCHA"
# add the latex directory to avoid os X 11.11 problems finding binaries
export PATH=$PATH:/usr/local/texlive/2016/bin/x86_64-darwin/
GOOD_RET=0
BAS_RET=1

# use very strict compilationg for c/c++
flags="-Wall -Wpedantic -Wextra"
alias gcc='gcc ${flags}'
alias g++='g++ ${flags}'
# assume we are using aspell for latex files. -t: latex, -c
alias aspell='aspell -t -c'

ARCHFLAGS="-arch x86_64" # Ensure user-installed binaries take precedence expor 
PATH=/usr/local/bin:/usr/local/mysql/bin/:$PATH # Load .bashrc/mysql if it exists
utilDir="$HOME/src_prh/GeneralUtil/"

reader()
{
    Open -a /Applications/Adobe\ Reader.app/ $@
}

RefCypherDebug()
{
    # refreshes the debugging database
    mysqldump -u root -p CypherAFM | mysql -u root -p DebugCypher
}

latex_git_diff()
{
    git diff --color-words --ignore-all-space $@
}

nuterm ()
{
    Open -a Terminal .
}

KillPy()
{
    # kills running python processes
    # -9: everything we can
    # awk is to get the PID
    kill -9 $(ps aux | grep '[p]ython*' | awk '{print $2}')
}

igordemos()
{
    # go to the demo directory...
    cd /Volumes/group/4Patrick/DemoData/IgorDemos/IgorPythonConvert/Output
}

bootcamp()
{
    cd /Users/patrickheenan/Documents/education/boulder_files/administrative/bootcamp_2015/code/IqBioBootcamp2015/
}

extra()
{
    cd /Users/patrickheenan/Documents/education/boulder_files/3_summer_2014/prep_physics
}

latexsty()
{
    cd /Users/patrickheenan/Library/texmf/tex/latex
}

fun()
{
    cd ~/Documents/fun/code/
}

pyNb()
{
    ipython notebook $@

}

pInit()
{
    hg init .
    cp "${utilDir}hg/.hgignore" ./.hgignore
}

viz()
{
    edu
    cd csci_7000_sci_viz/assignments/
}

protein()
{
    edu
    cd ..
    cd 1_fall_2014/csci_5415_mol_bio_alg/group_csci_5314/repo/csci5314_2014_conformation
}

mach()
{
    edu
    cd csci_5622_machine_learning/hw/ml-hw
}

gitInit()
{
    git init
    cp ~/utilities/git/.gitignore .

}

matnu()
{
    cp "${utilDir}mathematica/config.nb" ./$1.nb && open ./$1.nb
}

pynu()
{
    # copy the configuration files with the appropriate imports
    cp "${utilDir}python/config.py" ./$1.py
}

pynu_loc()
{
    # copy the configuration files with the appropriate imports
    cp "${utilDir}python/config_local.py" ./$1.py
}

igornu()
{
    cp "${utilDir}igor/_config.ipf" ./$1.ipf
}

bashnu()
{
    cp "${utilDir}bash/config.sh" $1.sh
}

mkcd()
{
    mkdir $1
    cd $1
}

emnu()
{
    cp "${utilDir}/latex/template.tex" ./${1}.tex
}

edu()
{
    cd /Users/patrickheenan/Documents/education/boulder_files/7_spring_2017
}

paper()
{
    cd /Users/patrickheenan/src_prh/Research/Personal/EventDetection/Docs/paper/drafts_biophys/drafts/scratch_md
}

euler()
{
    cd /Users/patrickheenan/Documents/qtWorkspace/algStudying/projectEuler/
}


gui()
{
   open -a Finder .
}

res()
{
    cd ~/src_prh/Research/Perkins/Projects
}

ms()
{
    cd ~/src_prh/Research/Personal/EventDetection/
}


p.()
{
    open -a Preview $@.pdf
}


p_pandoc()
{
    # see (or just man pandoc): pandoc.org/MANUAL.html
    # --filter      : use citeproc to generate citations, figure numbes
    # --bibliography: path to the zotero bibliography
    # --csl         : the style sheet to use with citeproc
    # --template    : the template to use 
    # --reference-docx: for getting better formatting
    # --from        : the type of format to use
    # --verbose     : print debugging info
    # -s            : make the file standalone
    # -o            : output
    # --metadata    : sets a relevant variable
    # note: metadata can be set as follows: 
    # stackoverflow.com/questions/26431719/pandoc-citations-without-appending-the-references-bibliography
    pandoc $1 $2 \
	--filter=./walk_figures.py\
	--filter=./fulfill_figures.py\
	--bibliography=${5:-./Masters.bib} \
	--from=markdown+yaml_metadata_block\
	--csl=${4:-biophysical-journal.csl}\
	--reference-docx=${3:-template_prh.docx}\
        --metadata link-citations=true\
	--verbose \
	-s -o $1.docx
    Open $1.docx
}

pcomp()
{
    set -x
    pandoc -V geometry:margin=1in  $1.md -o $1.pdf
}

platex2rtf()
{
    # -E: how to include figures
    # -d: debugging output
    latex2rtf -E0 -d 2 "$1" && Open ${1%.*}".rtf"
}

pdfl_all()
{
    pdflatex $1.tex
    bibtex $1.aux
    pdflatex $1.tex
    pdflatex $1.tex
    dvips $1.dvi -o $1.ps
    pstopdf $1.ps
}

pdfl()
{
    ERROR="Too few arguments : no file name specified"
    [[ $# -eq 0 ]] && echo $ERROR && return # no args? ... print error and exit

    # check that the file exists
    if [ -f $1.tex ] 
    then
	# if it exists then latex it twice, dvips, then ps2pdf, then remove all the unneeded files
	pdfl_all $1
	# these lines can be appended to delete other files, such as *.out
	rm *.blg
	rm *-blx.bib
	rm *.bbl
	rm *.run.xml
	rm *.aux
	rm *.log
	rm *.ps
	rm *.dvi
	rm *.toc
	rm *.lof
	rm *.nav
	rm *.snm
    else
	# otherwise give this output line with a list of available tex files
	echo 'the file doesnt exist butthead! Choose one of these:'
	ls *.tex
    fi

}



# Vieques address
#vieques=${identikey}@vieques.colorado.edu
clusterAddr=${identikey}@login.rc.colorado.edu
clusterHome="Users/pahe3165"

# XXX remove, for debugging below
# copying the code to the cluster (poor man's clone, wont copy files...)


getData()
{
    mat
    outputDir="computeOutput"
    rm -rf ${outputDir}
    mkdir ${outputDir}
    scp -r "${clusterAddr}:/${clusterHome}/logs/" ${outputDir}
    scp -r "${clusterAddr}:/${clusterBase}/output*" ${outputDir}
}

cPush()
{
    # essentially, a 'backwards' way to clone, using m localhost as 'remote'
    # must do 'hg clone repo ssh://xxxx' first: 
    #see:  http://stackoverflow.com/questions/2963040/how-to-clone-repository-to-a-remote-server-repository-with-mercurial
    hg push ssh://$clusterAddr/${clusterRepoRelative}
}

jila()
{
    server="jilau1.colorado.edu"
    addr=${identikey}@${server}
    ssh $@ ${addr}
}

compute()
{
    # ssh with the options...
    ssh $@ ${clusterAddr}
}

ref()
{
    source $base$profile
}

ed()
{
    Open -a emacs $@ &
}

nu()
{
	ed $base$profile	
	ref
}

# added by Anaconda3 2.1.0 installer
export PATH="//anaconda/bin:$PATH"

# added by Anaconda 2.1.0 installer
export PATH="//anaconda/bin:$PATH"

# added by Anaconda3 4.2.0 installer
export PATH="/Users/patrickheenan/anaconda/bin:$PATH"
