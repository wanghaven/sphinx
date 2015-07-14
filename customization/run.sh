#! /bin/bash

# allow arguments to be supplied
while [[ $# > 0 ]] ; do
	opt="$1"
	case $opt in
	    -p|--project)
			PROJECT="$2"; shift;;
		-a|--author)
			AUTHOR="$2"; shift;;
		-v|--version)
			VERSION="$2"; shift;;	
	    -d|--destination)
			DESTINATION="$2"; shift;;
		-f|--force-install)
			FORCEINSTALL=true;;
		-q|--quickstart)
			QUICKSTART=true;;
	    -h|--help)
	    	echo "usage: ./run.sh [OPTIONS] [ARGUMENTS]"; echo
	    	echo "Simplest (and recommended usage) is to run `./run.sh -f -p PROJECT -a AUTHOR -v VERSION`"
	    	echo "Note: please use the -f option carefully, it will overwrite an existing sphinx directory if needed."
	    	echo
	    	echo "=====OPTIONS====="
	    	echo "-h, --help : Displays this output. Note: when this argument is supplied no execution will occur."
	    	echo "-p, --project : REQUIRED. Name of the project directory where the code lives."
	    	echo "-a, --author: Author of the project."
	    	echo "-v, --version: Project's version number."
	    	echo "-d, --destination: Name of the directory to contain files needed for documentation. Set to /docs/ by default."
	    	echo "-f, --force-install: Enables forced installation and possible overwrite of an existing Sphinx directory."
	    	echo "-q, --quickstart: Enable manual configuration of sphinx-quickstart."
	    	exit 0;;
	    *)
	    	echo "ERROR: Invalid option: \""$opt"\"" 
	    	echo "run `./run.sh --help` to see usage.">&2
	    	exit 1;;
	esac
	shift
done

# project argument is required. will fail with error if not supplied
if [[ "$PROJECT" == "" ]]; then
    echo "ERROR: Option -n requires an argument for project name." >&2
    exit 1
fi

# destination will be set to /docs/ as default if not supplied
if [[ "$DESTINATION" == "" ]]; then
    echo "INFO: Option -d has either been unspecified or supplied no argument. Documentation source folder will be set to /docs/ by default." 
    DESTINATION="docs"
fi

# if --quickstart option isn't specified, then in order to run sphinx-quickstart automatically we need author and version info
if [[ "QUICKSTART" = "" ]] -a [[ "$AUTHOR" == "" || "$VERSION" == "" ]]; then
	echo "ERROR: sphinx-quickstart requires the author(s) and version for the project. Please either provide this information now, or run the script with the '--quickstart' option to supply this yourself later on." >&2
	exit 1
fi

# check if an input remains
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

#install and start up sphinx
cd ../
pip install --upgrade .
cd ../

if [[ "$QUICKSTART" = true ]]; then
	echo "NOTE: Follow instructions to get Sphinx set up. You may stick with the default selections for the entries, but just be sure to say YES to getting the autodoc extension."
	sphinx-quickstart
else
	sphinx-quickstart -p $PROJECT -a $AUTHOR -v $VERSION --ext-autodoc --ext-doctest --ext-intersphinx --quiet

#Sphinx's conf.py needs to know where to find the project modules from
echo "sys.path.insert(0, os.path.abspath('../'))" >> conf.py

#sphinx-apidoc autogenerates the .rst files from the project structure
sphinx-apidoc --force --module-first -o ./ ../$PROJECT

#let's go ahead and delete sphinx directory to minimze clutter
#remember: if we've made it down here then we know from earlier that sphinx/ dir didn't exist yet
rm -rf sphinx/

#set index.rst to what's in modules.rst
mv modules.rst index.rst
sed -i '' 's/4/2/' index.rst

#delete anything we can find involving test modules
sed -i '' '/test/d' ${PROJECT}.rst
find . -type f -name ${PROJECT}.tests\* -exec rm {} \;

#build the html files
make html

