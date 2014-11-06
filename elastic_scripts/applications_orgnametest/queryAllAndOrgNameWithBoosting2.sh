#!/bin/bash

curl -XPOST 'http://scdv-db02.sc.npm:9200/applicationorgnametest/_search?pretty=1' -d ' {
  "size": "100",
  "query": {
    "bool": {
      "should": [
        {
          "match": {
            "_all": "A E & F R BREWER LTD"
          }
        },
        {
          "wildcard": {
            "org_name": {
              "value": "A E & F R BREWER LTD",
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
