#! /bin/bash

#download Sphinx into a docs directory
mkdir docs/
cd docs/
git clone https://github.com/sphinx-doc/sphinx.git

#download and replace their apidoc.py with mine
cd sphinx/sphinx/
wget https://github.com/wanghaven/sphinx/raw/master/sphinx/apidoc.py

#install sphinx
cd ../
pip install --upgrade .

#run sphinx-quickstart
cd ../
echo "Follow instructions to get Sphinx set up. You may stick with the default selections for the entries, but just be sure to say YES to getting the autodoc extension."
sphinx-quickstart

#add path to where we reference the modules from to conf.py
echo "sys.path.insert(0, os.path.abspath('../../'))" >> source/conf.py

#run sphinx-apidoc
sphinx-apidoc --force --module-first -o ./ ../waldo

#link all rst files to index.rst
sed -i '' '/maxdepth/ a\
\ \ \ waldo
' index.rst

#build the html files
make html

