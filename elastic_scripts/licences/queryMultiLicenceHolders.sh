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
      "no_of_licences_held": {
        "gt": "11"
      }
    }
  }
}
