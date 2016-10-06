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
        "enabled": false
      },
      "properties": {
        "org_type_desc_whole": {
          "type": "string"
        },
        "licence_trading_names": {
          "type": "string",
          "analyzer": "companies"
        },
        "fabs_reference": {
          "type": "string"
        },
        "company_or_llp_no": {
          "type": "string"
        },
        "org_type_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "no_of_licences_held": {
          "type": "string"
        },
        "ref_data_id": {
          "type": "string"
        },
        "licence_traffic_area": {
          "type": "string",
          "index": "not_analyzed"
        },
        "org_name_wildcard": {
          "type": "string"
        },
        "lead_tc": {
          "type": "string"
        },
        "null": {
          "type": "string"
        },
        "case_count": {
          "type": "string"
        },
        "lic_id": {
          "type": "string"
        },
        "org_id": {
          "type": "string"
        },
        "is_mlh": {
          "type": "string"
        },
        "lic_no": {
          "type": "string"
        },
        "lic_status_desc_whole": {
          "type": "string"
        },
        "org_name": {
          "type": "string",
          "analyzer": "companies"
        },
        "ta_id": {
          "type": "string"
        },
        "lic_type_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_type_desc_whole": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_status_desc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "lic_status": {
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
