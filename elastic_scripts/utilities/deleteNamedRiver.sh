#!/bin/bash

river=$1

if [ "$#" -lt 1 ]; then
    echo "Parameters must include <index>"
    exit 1
fi

curl -XDELETE 'localhost:9200/_river/olcs_'$river'_river'
