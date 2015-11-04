curl -HGET 'http://elasticsearch-dev.olcs.mgt.mtpdvsa:9200/licence/_search?pretty' -d '{
  "version":"true",
  "query": {
    "term": {
      "is_mlh": "no"
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
        "field": "lic_status_desc"
      }
    }
  }
}'
