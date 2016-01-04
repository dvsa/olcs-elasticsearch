#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

curl -XGET -s "http://$ELASTIC_HOST:9200/_stats?pretty=1"