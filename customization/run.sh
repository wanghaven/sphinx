#! /bin/bash

#!/bin/bash
# Use > 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use > 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
while [[ $# > 0 ]] ; do
	opt="$1"
	case $opt in
	    -n|--name) 
			NAME="$2"; shift ;;
	    -d|--destination)
			case "$2" in
				""|-*|--*) DESTINATION='docs';;
				*) DESTINATION="$2"; shift;;
			esac;;
	    -s|--source)
	    	SOURCE="$2"; shift;;
	    --default)
	    	DEFAULT=YES;;
	    *)
	    	echo "ERROR: Invalid option: \""$opt"\"" >&2
	    	exit 1;;
	esac
	shift
done

if [[ "$NAME" == "" ]]; then
    echo "ERROR: Option -n requires an argument for project name." >&2
    exit 1
fi
echo DESTINATION = "${DESTINATION}"

if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 $1
fi

#download Sphinx into a docs directory
mkdir $DESTINATION
cd $DESTINATION
git clone https://github.com/sphinx-doc/sphinx.git

#download and replace their apidoc.py with mine
cd sphinx/sphinx/
rm apidoc.py
wget https://github.com/wanghaven/sphinx/raw/master/sphinx/apidoc.py

#install sphinx
cd ../
pip install --upgrade .

#run sphinx-quickstart
cd ../
echo "Follow instructions to get Sphinx set up. You may stick with the default selections for the entries, but just be sure to say YES to getting the autodoc extension."
sphinx-quickstart

#let's go ahead and delete sphinx directory to minimze clutter
rm -rf sphinx/

#add path to where we reference the modules from to conf.py
echo "sys.path.insert(0, os.path.abspath('../'))" >> conf.py

#run sphinx-apidoc
sphinx-apidoc --force --module-first -o ./ ../$NAME

#set index.rst to what's in modules.rst
mv modules.rst index.rst
sed -i '' 's/4/2/' index.rst

#delete anything we can find involving test modules
sed -i '' '/test/d' ${NAME}.rst
find . -type f -name ${NAME}.tests\* -exec rm {} \;

#build the html files
make html

