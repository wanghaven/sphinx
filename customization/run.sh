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
			NAME="$2"; shift;;
	    -d|--destination)
			DESTINATION="$2"; shift;;
		-f|--force-install)
			FORCEINSTALL = true;;
	    -h|--help)
	    	echo "usage: ./run.sh [OPTIONS] [ARGUMENTS]"
	    	echo "=====OPTIONS====="
	    	echo "-h, --help : Displays this output"
	    	echo "-n, --name : REQUIRED. Name of the project directory where the code lives"
	    	echo "-d, -destination: Name of the directory to contain files needed for documentation. Set to /docs/ by default."
	    	echo "-f, --force-install: Enables forced installation and possible overwrite of an existing Sphinx directory."
	    	exit 0;;
	    --default)
	    	DEFAULT=YES;;
	    *)
	    	echo "ERROR: Invalid option: \""$opt"\"" 
	    	echo "run `./run.sh --help` to see usage.">&2
	    	exit 1;;
	esac
	shift
done

if [[ "$NAME" == "" ]]; then
    echo "ERROR: Option -n requires an argument for project name." >&2
    exit 1
fi

if [[ "$DESTINATION" == "" ]]; then
    echo "INFO: Option -d has either been unspecified or supplied no argument. Documentation source folder will be set to /docs/ by default." 
    DESTINATION="docs"
fi

if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 $1
fi

#create directory for docs files
mkdir $DESTINATION
cd $DESTINATION

#check if sphinx directory already exists before cloning
if [ ! -d "sphinx" -o "$FORCEINSTALL" = true ]; then
	git clone https://github.com/sphinx-doc/sphinx.git
else
	echo "WARNING: sphinx directory already exists here. If you wish to overwrite existing directory, execute the script using the '--force-install' option." >&2
	exit 1
fi

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

#add path to where we reference the modules from to conf.py
echo "sys.path.insert(0, os.path.abspath('../'))" >> conf.py

#run sphinx-apidoc
sphinx-apidoc --force --module-first -o ./ ../$NAME

#let's go ahead and delete sphinx directory to minimze clutter
#remember: if we've made it down here then we know from earlier that sphinx/ dir didn't exist yet
rm -rf sphinx/

#set index.rst to what's in modules.rst
mv modules.rst index.rst
sed -i '' 's/4/2/' index.rst

#delete anything we can find involving test modules
sed -i '' '/test/d' ${NAME}.rst
find . -type f -name ${NAME}.tests\* -exec rm {} \;

#build the html files
make html

