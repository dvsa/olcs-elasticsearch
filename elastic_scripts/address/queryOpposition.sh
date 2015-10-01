{
  "query": {
    "bool": {
      "should": [
        {
          "wildcard": {
            "org_name_wildcard": {
              "value": "*",
              "boost": "2.0"
            }
          }
        },
        {
          "match": {
            "_all": "anything"
          }
        }
      ]
    }
  },
  "filter": {
    "range": {
      "oc_opposition_count": {
        "gt": "10"
      }
    }
  },
  "aggregations": {
    "counts": {
      "terms": {
        "field": "country_code"
      }
    }
  }
}
