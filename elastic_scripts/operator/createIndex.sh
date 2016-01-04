#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

version=${1:-1}

response=$(curl -XPUT -s $ELASTIC_HOST':9200/operator_v'$version -d '
{
  "mappings": {
    "operator": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "operator_ngram_analyzer"
      },
      "properties" : {
          "org_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "org_name" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "org_name_wildcard" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
         "is_irfo" : {
            "type" : "long",
            "include_in_all" : false
          },
         "no_of_licences_held" : {
            "type" : "long",
            "include_in_all" : false
          },
         "postcode" : {
            "type" : "string",
            "analyzer" : "operator_edgengram_analyzer"
          },
    	 "saon_desc" : {
            "type" : "string",
            "analyzer" : "operator_ngram_analyzer"
          },
         "town" : {
            "type" : "string",
            "analyzer" : "operator_ngram_analyzer"
          },
        "irfo_postcode" : {
            "type" : "string",
            "analyzer" : "operator_edgengram_analyzer"
          },
    	 "irfo_saon_desc" : {
            "type" : "string",
            "analyzer" : "operator_ngram_analyzer"
          },
         "irfo_town" : {
            "type" : "string",
            "analyzer" : "operator_ngram_analyzer"
          },
    	 "ta_id" : {
            "type" : "string",
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
        "operator_ngram_analyzer": {
          "tokenizer": "operator_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        },
        "operator_edgengram_analyzer": {
          "tokenizer": "operator_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "operator_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "operator_edgengram_tokenizer": {
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