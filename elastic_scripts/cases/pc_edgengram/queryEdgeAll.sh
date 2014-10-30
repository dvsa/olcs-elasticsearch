curl -XPOST "http://scdv-db02.sc.npm:9200/caseedge/_search?pretty=1" -d '{
  "size": "0",
  "query": {
    "match_all": {}
  },
  "aggregations": {
    "counts": {
      "terms": {
        "field": "postcode"
      }
    }
  }
}'
