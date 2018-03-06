#!/bin/sh

PROJECT=$(dirname $(readlink -f "$0"))

if [ -e $PROJECT/target ]; then
    docker run --rm -i -v $PROJECT:/src alpine:3.6 rm -rf /src/target
fi


# Guides
docker run --rm -i -v $PROJECT:/documents -v $PROJECT/target:/target difi/asciidoctor


# Fix ownership
docker run --rm -i -v $PROJECT:/src alpine:3.6 chown -R $(id -g $USER).$(id -g $USER) /src/target