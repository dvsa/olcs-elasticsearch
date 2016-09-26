#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

version=${1:-1}

response=$(curl -XPUT -s $ELASTIC_HOST':9200/vehicle_current_v'$version -d '
{
  "mappings": {
    "vehicle_current": {
      "_all": {
        "enabled": false
      },
      "properties": {
        "removal_date": {
          "type": "date",
          "format": "yyyy-MM-dd"
        },
        "disc_no": {
          "type": "string",
          "index": "not_analyzed"
        },
        "gd_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_no": {
          "type": "string"
        },
        "lic_veh_id": {
          "type": "string",
          "index": "not_analyzed"
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
        "ref_data_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "specified_date": {
          "type": "date",
          "format": "yyyy-MM-dd"
        },
        "lic_status_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_type_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "veh_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "vrm": {
          "type": "string",
          "analyzer": "vehicle_current_edgengram_analyzer"
        },
        "section_26": {
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
        "vehicle_current_edgengram_analyzer": {
          "tokenizer": "vehicle_current_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "vehicle_current_edgengram_tokenizer": {
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