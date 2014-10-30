curl -XPUT 'localhost:9200/application_v1' -d '
{
  "aliases" : {
      "application" : {}
  },
  "mappings": {
    "application": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "application_ngram_analyzer"
      },
      "properties" : {
          "app_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "app_status" : {
            "type" : "string"
          },
          "correspondence_postcode" : {
            "type" : "string",
            "analyzer" : "application_ngram_analyzer"
          },
          "lic_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "lic_no" : {
            "type" : "string",
            "analyzer" : "application_ngram_analyzer"
          },
          "lic_status" : {
            "type" : "string"
          },
          "lic_type" : {
            "type" : "string"
          },
          "name" : {
            "type" : "string",
            "analyzer" : "application_ngram_analyzer"
          },
          "org_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "received_date" : {
            "type" : "date",
            "format" : "dateOptionalTime"
          },
          "tot_auth_trailers" : {
            "type" : "long",
            "include_in_all" : false
          },
          "tot_auth_vehicles" : {
            "type" : "long",
            "include_in_all" : false
          }
        }
    }
  },
  "settings": {
    "analysis": {
      "analyzer": {
        "application_ngram_analyzer": {
          "tokenizer": "application_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        }
      },
      "tokenizer": {
        "application_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        }
      }
    }
  }
}
'
