#!/bin/bash

index=$1
version=${2:-1}

if [ "$#" -lt 1 ]; then
    echo "Parameters must include <index> <optional - version>"
    exit 1
fi

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

response=$(curl -XDELETE -s $ELASTIC_HOST':9200/'$index'_v'$version'')
if [ "$response" != "{\"acknowledged\":true}" ]; then
    echo $response
fi
