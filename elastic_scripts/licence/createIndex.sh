#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

version=${1:-1}

response=$(curl -XPUT -s $ELASTIC_HOST':9200/licence_v'$version -d '
{
  "mappings": {
    "licence": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "licence_ngram_analyzer"
      },
      "properties" : {
          "addr_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "case_count" : {
            "type" : "long",
            "include_in_all" : false
          },
         "no_of_licences_held" : {
            "type" : "long",
            "include_in_all" : false
          },
          "is_mlh" : {
            "type" : "string",
            "include_in_all" : false
          },
          "lead_tc" : {
            "type" : "string",
            "analyzer" : "licence_ngram_analyzer"
          },
          "lic_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "lic_status_desc" : {
            "type" : "string",
            "include_in_all" : false,
            "index" : "not_analyzed"
          },
          "lic_status_desc_whole" : {
            "type" : "string",
            "include_in_all" : false,
            "index" : "not_analyzed"
          },
          "lic_type_desc" : {
            "type" : "string",
            "include_in_all" : false,
            "index" : "not_analyzed"
          },
          "lic_type_desc_whole" : {
            "type" : "string",
            "include_in_all" : false,
            "index" : "not_analyzed"
          },
          "lic_no" : {
            "type" : "string",
            "analyzer" : "licence_ngram_analyzer"
          },
          "licence_traffic_area" : {
            "type" : "string",
            "include_in_all" : false,
            "index" : "not_analyzed"
          },
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
          "org_type_desc_whole" : {
            "type" : "string",
            "include_in_all" : false,
            "index" : "not_analyzed"
          },
          "org_type_desc" : {
            "type" : "string",
            "include_in_all" : false,
            "index" : "not_analyzed"
          },
          "ref_data_id" : {
            "type" : "string",
            "include_in_all" : false
          },
          "ta_id" : {
            "type" : "string",
            "include_in_all" : false
          },
          "trading_name" : {
            "type" : "string",
            "analyzer" : "licence_ngram_analyzer"
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
        "licence_ngram_analyzer": {
          "tokenizer": "licence_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        },
        "licence_edgengram_analyzer": {
          "tokenizer": "licence_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "licence_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "licence_edgengram_tokenizer": {
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
