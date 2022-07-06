#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

curl -XGET -s "https://$ELASTIC_HOST/_stats?pretty=1"