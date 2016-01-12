#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

version=${1:-1}

response=$(curl -XPUT -s $ELASTIC_HOST':9200/pi_hearing_v'$version -d '
{
  "mappings": {
    "pi_hearing": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "pi_hearing_ngram_analyzer"
      },
      "properties" : {
        "case_id" : {
            "type" : "long"
          },
        "lic_id" : {
            "type" : "long"
          },
        "pi_id" : {
            "type" : "long"
          },
        "pv_id" : {
            "type" : "long"
          },
        "ph_id" : {
            "type" : "long"
          },
        "org_id" : {
            "type" : "long"
          },
        "hearing_date_time" : {
            "type" : "date",
            "format" : "dateOptionalTime"
          },
        "venue" : {
            "type" : "string",
            "analyzer" : "pi_hearing_ngram_analyzer"
          },
        "lic_no" : {
              "type" : "string",
              "analyzer" : "pi_hearing_ngram_analyzer"
          },
        "org_name" : {
              "type" : "string",
              "index" : "not_analyzed"
          },
        "org_name_wildcard" : {
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
        "pi_hearing_ngram_analyzer": {
          "tokenizer": "pi_hearing_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        },
        "pi_hearing_edgengram_analyzer": {
          "tokenizer": "pi_hearing_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "pi_hearing_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "pi_hearing_edgengram_tokenizer": {
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
)