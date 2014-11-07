curl -XPUT 'localhost:9200/vehicle_current_v1' -d '
{
  "aliases": {
    "vehicle_current": {}
  },
  "mappings": {
    "vehicle": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "vehicle_current_ngram_analyzer"
      },
      "properties": {
        "deleted_date": {
          "type": "date",
          "format": "dateOptionalTime",
          "include_in_all": false
        },
        "disc_no": {
          "type": "string"
        },
        "gd_id": {
          "type": "long",
          "include_in_all": false
        },
        "lic_id": {
          "type": "long",
          "include_in_all": false
        },
        "lic_no": {
          "type": "string"
        },
        "lic_veh_id": {
          "type": "long",
          "include_in_all": false
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
        "ref_data_id": {
          "type": "string",
          "include_in_all": false
        },
        "specified_date": {
          "type": "date",
          "format": "dateOptionalTime",
          "include_in_all": false
        },
        "lic_status_desc": {
          "type": "string",
          "include_in_all": false
        },
        "lic_type_desc": {
          "type": "string",
          "include_in_all": false
        },
        "veh_id": {
          "type": "long",
          "include_in_all": false
        },
        "vrm": {
          "type": "string"
        }
      }
    }
  },
  "settings": {
    "analysis": {
      "analyzer": {
        "vehicle_current_ngram_analyzer": {
          "tokenizer": "vehicle_current_ngram_tokenizer",
          "filter": [
            "standard",
            "lowercase",
            "stop"
          ]
        }
      },
      "tokenizer": {
        "vehicle_current_ngram_tokenizer": {
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
