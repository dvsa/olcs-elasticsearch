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
          "user_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "role_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "org_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "con_det_id" : {
            "type" : "long",
            "include_in_all" : false
        },
          "identity_pid" : {
            "type" : "string",
            "include_in_all" : false
          },
        "team_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "email_address" : {
            "type" : "string",
            "analyzer" : "user_ngram_analyzer"
          },
          "forename" : {
            "type" : "string",
            "analyzer" : "user_ngram_analyzer"
          },
        "family_name" : {
            "type" : "string",
            "analyzer" : "user_ngram_analyzer"
          },
          "team_name" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "org_name" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "org_name_wildcard" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "user_type" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "role" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "description" : {
            "type" : "string",
            "analyzer" : "user_ngram_analyzer"
          },
          "partner_name" : {
              "type" : "string",
              "index" : "not_analyzed"
          },
          "la_name" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "deleted_date" : {
              "type" : "date",
              "format": "yyyy-MM-dd"
          },"entity" : {
              "type" : "string",
              "index" : "not_analyzed"
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
