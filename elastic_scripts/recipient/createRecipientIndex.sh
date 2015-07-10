curl -XPUT 'localhost:9200/recipient_v1' -d '
{
  "aliases" : {
      "recipient" : {}
  },
  "mappings": {
    "recipient": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "recipient_ngram_analyzer"
      },
      "properties" : {
        "ta_id" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
        "r_id" : {
            "type" : "long"
          },
        "hearing_date_time" : {
            "type" : "date",
            "format" : "dateOptionalTime"
          },
        "venue" : {
            "type" : "string",
            "analyzer" : "recipient_ngram_analyzer"
          },
        "contact_name" : {
              "type" : "string",
              "analyzer" : "recipient_ngram_analyzer"
          },
        "email_address" : {
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
        "recipient_ngram_analyzer": {
          "tokenizer": "recipient_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        },
        "recipient_edgengram_analyzer": {
          "tokenizer": "recipient_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "recipient_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "recipient_edgengram_tokenizer": {
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
