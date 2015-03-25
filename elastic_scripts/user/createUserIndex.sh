curl -XPUT 'localhost:9200/user_v1' -d '
{
  "aliases" : {
      "user" : {}
  },
  "mappings": {
    "user": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "user_ngram_analyzer"
      },
      "properties" : {
          "app_id" : {
            "type" : "long"
          },
          "app_status_desc" : {
            "type" : "string"
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
            "type" : "string"
          },
          "lic_type_desc" : {
            "type" : "string"
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
        "user_ngram_analyzer": {
          "tokenizer": "user_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        },
        "user_edgengram_analyzer": {
          "tokenizer": "user_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "user_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "user_edgengram_tokenizer": {
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
