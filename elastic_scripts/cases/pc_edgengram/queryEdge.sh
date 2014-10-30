curl -XPOST "http://scdv-db02.sc.npm:9200/caseedge/_search?pretty=1" -d '{
  "size": "10",
  "query": {
    "match": {
      "postcode": "B13dd"
    }
  },
  "aggregations": {
    "counts": {
      "terms": {
        "field": "postcode"
      }
    }
  }
}'
