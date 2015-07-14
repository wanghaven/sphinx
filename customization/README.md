This script is intended to automate as much of the documentation creation as possible.

Usage: Download the run.sh script into the root directory of a project and ensure it has permission to run by executing `chmod u+x run.sh`.
The usage looks like - `./run.sh [OPTIONS] [ARGUMENTS]`

Arguments that may be supplied:
-h, --help : Displays the help output.
-n, --name : REQUIRED. Name of the project directory where the code lives.
-d, -destination: Name of the directory to contain files needed for documentation. Set to /docs/ by default.
-f, --force-install: Enables forced installation and possible overwrite of an existing Sphinx directory.


Notes:
7/14/15: As of now, only creates documentation for the API, and will also tamper with existing docs file structure in index.rst, assuming there is an existing project for the documentation that uses index.rst as the root file. 
