curl -HGET 'http://scdv-db02.sc.npm:9200/_search?pretty' -d '{
  "query": {
    "term": {
      "app_status_desc": "under"
    }
  },
  "aggregations": {
    "counts": {
      "terms": {
        "field": "_index"
      },
      "aggregations": {
        "lic_status": {
          "terms": {
            "field": "lic_status_desc"
          }
        }
      }
    },
    "status": {
      "terms": {
        "field": "app_status_desc"
      }
    }
  }
}'
