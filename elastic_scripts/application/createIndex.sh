#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

version=${1:-1}

response=$(curl -XPUT -s $ELASTIC_HOST':9200/application_v'$version -d '
{
  "mappings": {
    "application": {
      "_all": {
        "enabled": false
      },
      "properties": {
        "app_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "app_status_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "correspondence_postcode": {
          "type": "string"
        },
        "lic_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_no": {
          "type": "string"
        },
        "lic_status_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_type_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "org_name": {
          "type": "string",
          "analyzer": "companies"
        },
        "org_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "org_name_wildcard": {
          "type": "string"
        },
        "received_date": {
          "type": "date",
          "format": "yyyy-MM-dd"
        },
        "tot_auth_trailers": {
          "type": "long",
          "index": "not_analyzed"
        },
        "tot_auth_vehicles": {
          "type": "long",
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