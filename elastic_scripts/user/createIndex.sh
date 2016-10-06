#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

version=${1:-1}

response=$(curl -XPUT -s $ELASTIC_HOST':9200/user_v'$version -d '
{
  "mappings": {
    "user": {
      "_all": {
        "enabled": false
      },
      "properties": {
        "user_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "role_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "org_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "login_id": {
          "type": "string"
        },
        "con_det_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "identity_pid": {
          "type": "string",
          "index": "not_analyzed"
        },
        "team_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "email_address": {
          "type": "string",
          "analyzer": "urls-links-emails"
        },
        "forename": {
          "type": "string"
        },
        "family_name": {
          "type": "string"
        },
        "full_name": {
          "type": "string"
        },
        "team_name": {
          "type": "string",
          "index": "not_analyzed"
        },
        "org_name": {
          "type": "string",
          "index": "not_analyzed"
        },
        "org_name_wildcard": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_nos": {
          "type": "string",
              "analyzer" : "comma_sep"
        },
        "user_type": {
          "type": "string",
          "index": "not_analyzed"
        },
        "role": {
          "type": "string",
          "index": "not_analyzed"
        },
        "description": {
          "type": "string",
          "index": "not_analyzed"
        },
        "partner_name": {
          "type": "string",
          "index": "not_analyzed"
        },
        "la_name": {
          "type": "string",
          "index": "not_analyzed"
        },
        "deleted_date": {
          "type": "date",
          "format": "yyyy-MM-dd"
        },
        "entity": {
          "type": "string",
          "analyzer": "companies"
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
        },
        "names": {
          "tokenizer": "standard",
          "filter": [
            "standard",
            "lowercase"
          ]
        },
        "urls-links-emails": {
          "type": "custom",
          "tokenizer": "uax_url_email",
          "filter" : [ "lowercase" ]
        },
        "lowercase": {
          "type": "custom",
          "tokenizer": "keyword",
          "filter": [
            "lowercase"
          ]
        },
        "comma_sep": {
          "type": "custom",
          "tokenizer": "comma",
          "filter": [
            "lowercase"
          ]
        }
      },
      "tokenizer": {
        "comma": {
          "type": "pattern",
          "pattern": ", "
        }
      }
    }
  }
}
'
)
