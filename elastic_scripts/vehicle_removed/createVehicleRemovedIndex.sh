curl -XPUT 'localhost:9200/vehicle_removed_v1' -d '
{
  "aliases": {
    "vehicle_removed": {}
  },
  "mappings": {
    "vehicle": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "vehicle_removed_ngram_analyzer"
      },
      "properties": {
        "removal_date": {
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
          "include_in_all": false,
          "index" : "not_analyzed"
        },
        "lic_type_desc": {
          "type": "string",
          "include_in_all": false,
          "index" : "not_analyzed"
        },
        "veh_id": {
          "type": "long",
          "include_in_all": false
        },
        "vrm": {
          "type": "string",
          "analyzer": "vehicle_removed_edgengram_analyzer"
        },
        "section_26": {
            "type": "integer",
            "include_in_all": false
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
        "vehicle_removed_ngram_analyzer": {
          "tokenizer": "vehicle_removed_ngram_tokenizer",
          "filter": [
            "standard",
            "lowercase",
            "stop"
          ]
        },
        "vehicle_removed_edgengram_analyzer": {
          "tokenizer": "vehicle_removed_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "vehicle_removed_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "vehicle_removed_edgengram_tokenizer": {
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