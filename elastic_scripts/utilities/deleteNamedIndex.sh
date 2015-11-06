#!/bin/bash

index=$1
version=${2:-1}  

if [ "$#" -lt 1 ]; then
    echo "Parameters must include <index> <optional - version>"
    exit 1
fi

curl -XDELETE 'localhost:9200/'$index'_v'$version''
