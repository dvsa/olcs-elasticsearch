#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

curl -XGET "https://$ELASTIC_HOST/_settings?pretty=1"
