#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

version=${1:-1}

response=$(curl -XPUT -s $ELASTIC_HOST':9200/irfo_v'$version -d '
{
  "mappings": {
    "irfo": {
      "_all": {
        "enabled": false
      },
      "properties" : {
          "org_id" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "org_name" : {
            "type" : "string",
            "analyzer" : "companies"
          },
          "org_name_wildcard" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "org_type_desc" : {
            "type" : "string",
          "index": "not_analyzed"
          },
          "organisation_trading_names" : {
            "type" : "string",
             "analyzer" : "companies",
              "analyzer" : "pipe_sep"

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
        "companies": {
          "type": "standard",
          "stopwords": [
            "a",
            "an",
            "and",
            "&",
            "are",
            "as",
            "at",
            "be",
            "but",
            "by",
            "for",
            "if",
            "in",
            "into",
            "is",
            "it",
            "no",
            "not",
            "of",
            "on",
            "or",
            "such",
            "that",
            "the",
            "their",
            "then",
            "there",
            "these",
            "they",
            "this",
            "to",
            "was",
            "will",
            "with",
            "limited",
            "ltd",
            "plc",
            "inc",
            "incorporated",
            "llp"
          ]
        },
        "lowercase": {
          "type": "custom",
          "tokenizer": "keyword",
          "filter": [
            "lowercase"
          ]
        },
        "pipe_sep": {
          "type" : "custom",
          "tokenizer" : "pipe",
          "filter": ["lowercase"]
        }
      },
      "tokenizer": {
        "pipe" : {
            "type" : "pattern",
            "pattern" : "|"
        }
      }
    }
  }
}
'
)