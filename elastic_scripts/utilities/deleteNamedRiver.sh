#!/bin/bash

river=$1

if [ "$#" -lt 1 ]; then
    echo "Parameters must include <index>"
    exit 1
fi

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

RESPONSE=$(curl -XDELETE -s $ELASTIC_HOST':9200/_river/olcs_'$river'_river')
if [[ $RESPONSE != "{\"acknowledged\":true}" ]]; then
    echo Error deleting river
    echo $RESPONSE
fi

