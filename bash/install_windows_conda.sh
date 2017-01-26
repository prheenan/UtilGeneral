function python_install {
	conda install $@ --yes
	conda update $@
}
python_install numpy
python_install scipy
python_install matplotlib
python_install pip
python -m pip install igor
