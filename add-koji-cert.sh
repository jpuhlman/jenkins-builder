#!/bin/bash

if [ -e ~jenkins/.koji/serverca.crt ] ; then
        mkdir -p /usr/local/share/ca-certificates/extra
        cp ~jenkins/.koji/serverca.crt /usr/local/share/ca-certificates/extra/
        update-ca-certificates
fi
