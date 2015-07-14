This script is intended to automate as much of the documentation creation as possible.

Usage: Download the run.sh script into the root directory of a project and ensure it has permission to run by executing `chmod u+x run.sh`.
The usage looks like - `./run.sh [OPTIONS] [ARGUMENTS]`

Arguments that may be supplied:
-h, --help : Displays the help output.
-n, --name : REQUIRED. Name of the project directory where the code lives.
-d, -destination: Name of the directory to contain files needed for documentation. Set to /docs/ by default.
-f, --force-install: Enables forced installation and possible overwrite of an existing Sphinx directory.

The name supplied should be the name of the project directory in order for Sphinx to locate the project source code. The default directory where the documentation will live will be at `/docs/`, so unless there is an existing directory with this name, it is suggested that no destination for the docs files be given. 




Notes:
7/14/15: As of now, only creates documentation for the API, and will also tamper with existing docs file structure in index.rst, assuming there is an existing project for the documentation that uses index.rst as the root file. 
