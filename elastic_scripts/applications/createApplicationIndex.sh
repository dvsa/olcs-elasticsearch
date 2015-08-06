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
            "type" : "long"
          },
          "app_status_desc" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "correspondence_postcode" : {
            "type" : "string",
            "analyzer" : "application_edgengram_analyzer"
          },
          "lic_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "lic_no" : {
            "type" : "string",
            "analyzer" : "application_ngram_analyzer"
          },
          "lic_status_desc" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "lic_type_desc" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "org_name" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "org_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "org_name_wildcard" : {
            "type" : "string",
            "index" : "not_analyzed"
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
      "char_filter" : {
        "spaces_removed_pattern":{
          "type":"pattern_replace",
          "pattern":"\\s",
          "replacement":""
        } 
      },
      "analyzer": {
        "application_ngram_analyzer": {
          "tokenizer": "application_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        },
        "application_edgengram_analyzer": {
          "tokenizer": "application_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
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
        },
        "application_edgengram_tokenizer": {
          "type": "edgeNGram",
          "min_gram": "2",
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
