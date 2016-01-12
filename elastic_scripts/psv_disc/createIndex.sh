#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

version=${1:-1}

response=$(curl -XPUT -s $ELASTIC_HOST':9200/psv_disc_v'$version -d '
{
  "mappings": {
    "psv_disc": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "psv_disc_ngram_analyzer"
      },
      "properties": {
        "disc_no": {
          "type": "string"
        },
        "lic_id": {
          "type": "long",
          "include_in_all": false
        },
        "lic_no": {
          "type": "string"
        },
        "org_id": {
          "type": "long",
          "include_in_all": false
        },
        "org_name": {
          "type": "string",
          "index" : "not_analyzed"
        },
        "org_name_wildcard": {
          "type": "string",
          "index" : "not_analyzed"
        },
        "psv_id": {
          "type": "long",
          "include_in_all": false
        },
        "lic_status_desc": {
          "type": "string",
          "index" : "not_analyzed"
        },
        "lic_type_desc": {
          "type": "string",
          "include_in_all": false,
          "index" : "not_analyzed"
        }
      }
    }
  },
  "settings": {
    "analysis": {
      "analyzer": {
        "psv_disc_ngram_analyzer": {
          "tokenizer": "psv_disc_ngram_tokenizer",
          "filter": [
            "standard",
            "lowercase",
            "stop"
          ]
        }
      },
      "tokenizer": {
        "psv_disc_ngram_tokenizer": {
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
)