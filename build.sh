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
#docker run --rm -i -v $PROJECT/target/site/files:/src alpine:3.6 rm -rf /src/SG-PEPPOLBIS-eDocs-Schematron.zip
#docker run --rm -i -v $PROJECT/target/schematron:/src -v $PROJECT/target/site/files:/target -w /src kramos/alpine-zip -r /target/SG-PEPPOLBIS-eDocs-Schematron.zip .

rm -rf $PROJECT/target/site/files/SG-PEPPOLBIS-eDocs-Schematron.zip

cd $PROJECT
zip -r target/site/files/SG-PEPPOLBIS-eDocs-Schematron.zip rules/sch

# Example files
#docker run --rm -i -v $PROJECT/target/site/files:/src alpine:3.6 rm -rf /src/SG-PEPPOLBIS-eDocs-Examples.zip
#docker run --rm -i -v $PROJECT/rules/examples:/src -v $PROJECT/target/site/files:/target -w /src kramos/alpine-zip -r /target/SG-PEPPOLBIS-eDocs-Examples.zip .
rm -rf $PROJECT/target/site/files/SG-PEPPOLBIS-eDocs-Examples.zip

cd $PROJECT
zip -r target/site/files/SG-PEPPOLBIS-eDocs-Examples.zip rules/examples 

# UBL XSD
#docker run --rm -i -v $PROJECT/target/site/files:/src alpine:3.6 rm -rf /src/UBL-AppResp-Ord-OrdResp-xsd.zip
#docker run --rm -i -v $PROJECT/ubl-xsd:/src -v $PROJECT/target/site/files:/target -w /src kramos/alpine-zip -r /target/UBL-AppResp-Ord-OrdResp-xsd.zip .

rm -rf $PROJECT/target/site/files/UBL-AppResp-Ord-OrdResp-xsd.zip

cd $PROJECT
zip -r target/site/files/UBL-AppResp-Ord-OrdResp-xsd.zip ubl-xsd


# Guides
docker run --rm -i -v $PROJECT:/documents -v $PROJECT/target:/target difi/asciidoctor

# Fix ownership
docker run --rm -i -v $PROJECT:/src alpine:3.6 chown -R $(id -g $USER).$(id -g $USER) /src/target
