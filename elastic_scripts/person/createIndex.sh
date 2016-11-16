#!/bin/bash

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

version=${1:-1}

response=$(curl -XPUT -s $ELASTIC_HOST':9200/person_v'$version -d '
{
  "mappings": {
    "person": {
      "_all": {
        "enabled": false
      },
      "properties": {
        "person_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "org_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "tm_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "contact_type": {
          "type": "string",
          "index": "not_analyzed"
        },
        "person_forename": {
          "type": "string"
        },
        "person_forename_wildcard": {
          "type": "string",
          "index": "not_analyzed"
        },
        "person_family_name": {
          "type": "string"
        },
        "person_fullname": {
          "type": "string"

        },
        "person_family_name_wildcard": {
          "type": "string",
          "index": "not_analyzed"
        },
        "person_birth_date": {
          "type": "date",
          "format": "yyyy-MM-dd"
        },
        "person_other_name": {
          "type": "string",
          "index": "not_analyzed"
        },
        "person_other_name_wildcard": {
          "type": "string",
          "index": "not_analyzed"
        },
        "person_birth_place": {
          "type": "string"
        },
        "person_title": {
          "type": "string"
        },
        "person_deleted": {
          "type": "date",
          "format": "yyyy-MM-dd"
        },
        "person_created_on": {
          "type": "date",
          "format": "yyyy-MM-dd"
        },
        "org_name": {
          "type": "string",
          "analyzer": "companies"
        },
        "org_type": {
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
        "lic_type_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "traffic_area": {
          "type": "string",
          "index": "not_analyzed"
        },
        "ta_code": {
          "type": "string",
          "index": "not_analyzed"
        },
        "tm_status_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "found_as": {
          "type": "string",
          "index": "not_analyzed"
        },
        "date_added": {
          "type": "date",
          "format": "yyyy-MM-dd"
        },
        "date_removed": {
          "type": "date",
          "format": "yyyy-MM-dd"
        },
        "disqualified": {
          "type": "string",
          "index": "not_analyzed"
        },
        "case_id": {
          "type": "string",
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
      "filter": {
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
        }
      }
    }
  }
}
'
)
