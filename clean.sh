#!/bin/bash

clean() {
    echo "cleaning directory."
    rm *.tar.gz
    rm -R -- */
}

clean