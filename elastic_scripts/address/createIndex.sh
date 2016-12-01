#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

version=${1:-1}

response=$(curl -XPUT -s $ELASTIC_HOST':9200/address_v'$version -d '
{
  "mappings": {
    "address": {
      "_all": {
        "enabled": false
      },
      "properties": {
        "addr_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "org_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "oc_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "loc_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "app_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_no": {
          "type": "string"
        },
        "lic_status": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_status_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "app_status_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "address_type": {
          "type": "string",
          "index": "not_analyzed"
        },
        "paon_desc": {
          "type": "string"
        },
        "saon_desc": {
          "type": "string"
        },
        "street": {
          "type": "string"
        },
        "locality": {
          "type": "string"
        },
        "town": {
          "type": "string"
        },
        "postcode": {
          "type": "string",
          "analyzer" : "address_edgengram_analyzer"
        },
        "full_address": {
          "type": "string"
        },
        "country_code": {
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
        "complaint_case_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "opposition_case_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "complaint": {
          "type": "string",
          "index": "not_analyzed"
        },
        "opposition": {
          "type": "string",
          "index": "not_analyzed"
        },
        "deleted_date": {
          "type": "date",
          "index": "not_analyzed"
        },
        "created_on": {
          "type": "date",
          "index": "not_analyzed"
        },
        "goods_or_psv_desc": {
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
        },
        "lowercase": {
          "type": "custom",
          "tokenizer": "keyword",
          "filter": [
            "lowercase"
          ]
        },
        "address_edgengram_analyzer": {
          "tokenizer": "address_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "address_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "3",
          "max_gram": "8",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "address_edgengram_tokenizer": {
          "type": "edgeNGram",
          "min_gram": "3",
          "max_gram": "8",
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
