curl -XPUT 'localhost:9200/vehicle_v1' -d '
{
  "aliases" : {
      "vehicles" : {},
      "psv" : {
            "filter" : {
                "term" : {"_type" : "psv" }
            }
      },
      "goods_current" : {
            "filter" : {
                "term" : {"_type" : "goods_current" }
            }
      },
      "goods_removed" : {
            "filter" : {
                "term" : {"_type" : "goods_removed" }
            }
      }
  },
  "mappings": {
    "psv": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "psv_vehicle_ngram_analyzer"
      },
      "properties" : {
          "disc_no" : {
            "type" : "string"
          },
          "lic_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "lic_no" : {
            "type" : "string"
          },
          "org_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "org_name" : {
            "type" : "string",
            "analyzer" : "psv_vehicle_ngram_analyzer"
          },
          "psv_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "status" : {
            "type" : "string",
            "include_in_all" : false
          },
          "type_of_licence" : {
            "type" : "string",
            "include_in_all" : false
          }
       }
    },
    "goods": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "vehicle_ngram_analyzer"
      },
      "properties" : {
          "deleted_date" : {
            "type" : "date",
            "format" : "dateOptionalTime",
            "include_in_all" : false
          },
          "disc_no" : {
            "type" : "string"
          },
          "gd_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "lic_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "lic_no" : {
            "type" : "string"
          },
          "lic_veh_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "org_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "org_name" : {
            "type" : "string",
            "analyzer" : "vehicle_ngram_analyzer"
          },
          "ref_data_id" : {
            "type" : "string",
            "include_in_all" : false
          },
          "specified_date" : {
            "type" : "date",
            "format" : "dateOptionalTime",
            "include_in_all" : false
          },
          "status" : {
            "type" : "string",
            "include_in_all" : false
          },
          "type_of_licence" : {
            "type" : "string",
            "include_in_all" : false
          },
          "veh_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "vrm" : {
            "type" : "string"
          }
        }
      }
  },
  "settings": {
    "analysis": {
      "analyzer": {
        "vehicle_ngram_analyzer": {
          "tokenizer": "vehicle_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        },
        "psv_vehicle_ngram_analyzer": {
          "tokenizer": "psv_vehicle_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        }
      },
      "tokenizer": {
        "vehicle_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "psv_vehicle_ngram_tokenizer": {
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
