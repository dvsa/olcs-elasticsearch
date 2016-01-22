curl "localhost:9200/_search?pretty=1" -d '{
  "size": 0,
  "aggregations": {
    "count_by_index": {
      "terms": {
        "field": "_index",
        "size": 100
      }
    }
  }
}'
