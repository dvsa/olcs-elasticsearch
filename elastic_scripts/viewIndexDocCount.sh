curl -XGET 'http://localhost:9200/_search' -d '{
  "size": "0",
  "query": {
    "match_all": {}
  },
  "aggregations": {
    "counts": {
      "terms": {
        "field": "_index"
      }
    }
  }
}'
