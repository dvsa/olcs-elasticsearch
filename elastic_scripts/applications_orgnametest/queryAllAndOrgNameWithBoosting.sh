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
            "org_name": {
              "value": "C.R.F. (HOLDINGS) LTD",
              "boost": "2.0"
            }
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
