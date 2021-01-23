# GCC cross compiler utility script

#### WARNING: use the following commands / included scripts at your own risk. Never run commands or scripts you do not fully understand.

## Running:
edit variables inside .bash file and run:

    source .bash

next, install the following packages:

* make/gcc (apt install build-essential)
* bison
* flex
* libgmp3-dev
* libmpc-dev
* libmpfr-dev
* texinfo

after installing each package, run the build script with:

    ./build.sh

If you did not run the .bash file in the beginning you will need to run:

    chmod u+x *.sh && ./build.sh
