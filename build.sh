#!/bin/sh

PROJECT=$(dirname $(readlink -f "$0"))

# Delete target folder if found
if [ -e $PROJECT/target ]; then
    docker run --rm -i -v $PROJECT:/src alpine:3.6 rm -rf /src/target
fi

# Structure
docker run --rm -i \
    -v $PROJECT:/src \
    -v $PROJECT/target:/target \
    difi/vefa-structure:0.6.1

# Testing validation rules
docker run --rm -i -v $PROJECT:/src anskaffelser/validator:2.1.0 build -x -t -n eu.peppol.poacc.upgrade.v3 -a rules -target target/validator-test /src

# Schematron
for sch in $PROJECT/rules/sch/*.sch; do
    docker run --rm -i -v $PROJECT:/src -v $PROJECT/target/schematron:/target klakegg/schematron prepare /src/rules/sch/$(basename $sch) /target/$(basename $sch)
done

# Fix ownership
docker run --rm -i -v $PROJECT:/src alpine:3.6 chown -R $(id -g $USER).$(id -g $USER) /src/target

sudo rm -rf $PROJECT/target/site/files/SG-PEPPOLBIS-eDocs-Schematron.zip
sudo rm -rf $PROJECT/target/site/files/SG-PEPPOLBIS-eDocs-Examples.zip

cd $PROJECT/target
sudo zip -r site/files/SG-PEPPOLBIS-eDocs-Schematron.zip schematron/

cd $PROJECT
sudo zip -r target/site/files/SG-PEPPOLBIS-eDocs-Examples.zip rules/examples 


rm -rf $PROJECT/target/site/files/UBL-AppResp-Ord-OrdResp-xsd.zip

cd $PROJECT
zip -r target/site/files/UBL-AppResp-Ord-OrdResp-xsd.zip ubl-xsd


# Guides
docker run --rm -i -v $PROJECT:/documents -v $PROJECT/target:/target difi/asciidoctor

# Fix ownership
docker run --rm -i -v $PROJECT:/src alpine:3.6 chown -R $(id -g $USER).$(id -g $USER) /src/target
