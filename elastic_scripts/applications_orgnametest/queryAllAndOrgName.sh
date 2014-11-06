#!/bin/bash

curl -XPOST 'http://scdv-db02.sc.npm:9200/applicationorgnametest/_search?pretty=1' -d ' {
  "query": {
    "bool": {
      "should": [
        {
          "match": {
            "_all": "C.R.F. (HOLDINGS) LTD"
          }
        },
        {
          "wildcard": {
            "org_name": "C.R.F. (HOLDINGS) LTD"
          }
        }
      ]
    }
  },
  "aggregations": {
    "counts": {
      "terms": {
        "field": "_type"
      }
    }
  }
}'
