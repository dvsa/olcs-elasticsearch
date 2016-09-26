#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

version=${1:-1}

response=$(curl -XPUT -s $ELASTIC_HOST':9200/case_v'$version -d '
{
  "mappings": {
    "case": {
      "_all": {
        "enabled": false
      },
      "properties": {
        "app_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "case_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "app_status_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_status_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "case_type_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "case_status_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "case_desc": {
          "type": "string"
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
        "open_date": {
          "type": "date",
          "format": "yyyy-MM-dd"
        },
        "org_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "org_name": {
          "type": "string",
          "analyzer": "companies"
        },
        "org_name_wildcard": {
          "type": "string",
          "index": "not_analyzed"
        },
        "tm_family_name": {
          "type": "string"

        },
        "tm_forename": {
          "type": "string"

        },
        "tm_name": {
          "type": "string"

        },
        "tm_id": {
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
