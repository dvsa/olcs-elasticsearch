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
        "enabled": false
      },
      "properties": {
        "disc_no": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_id": {
          "type": "string"
        },
        "lic_no": {
          "type": "string"
        },
        "org_id": {
          "type": "string"
        },
        "org_name": {
          "type": "string",
          "analyzer": "companies"
        },
        "org_name_wildcard": {
          "type": "string",
          "index": "not_analyzed"
        },
        "psv_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_status_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_type_desc": {
          "type": "string",
          "index": "not_analyzed"
        }
      }
    }
  },
  "settings": {
    "analysis": {
      "char_filter": {
        "spaces_removed_pattern": {
          "type": "pattern_replace",
          "pattern": "\\s",
          "replacement": ""
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
        }
      }
    }
  }
}
'
)