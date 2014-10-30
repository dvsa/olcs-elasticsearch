curl -XPOST "http://scdv-db02.sc.npm:9200/case_suggester/_search?pretty=1" -d '{
  "size": "0",
  "suggest": {
    "my_suggester": {
      "text": "BD",
      "completion": {
        "field": "postcode"
      }
    }
  }
}'
