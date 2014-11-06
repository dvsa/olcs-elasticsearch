#!/bin/bash

curl -XGET "http://localhost:9200/applicationorgnametest/_all/_analyze?pretty=1" -d 'KNAPPHILL LIFTINSURANCE LOVEMEVERYDAY LENCOLL'
