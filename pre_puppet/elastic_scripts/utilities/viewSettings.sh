#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

curl -XGET "http://$ELASTIC_HOST:9200/_settings?pretty=1"
