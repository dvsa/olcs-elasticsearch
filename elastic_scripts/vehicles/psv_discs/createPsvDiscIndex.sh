curl -XPUT 'localhost:9200/psv_disc_v1' -d '
{
  "aliases": {
    "psv_disc": {}
  },
  "mappings": {
    "psv_disc": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "psv_disc_ngram_analyzer"
      },
      "properties": {
        "disc_no": {
          "type": "string"
        },
        "lic_id": {
          "type": "long",
          "include_in_all": false
        },
        "lic_no": {
          "type": "string"
        },
        "org_id": {
          "type": "long",
          "include_in_all": false
        },
        "org_name": {
          "type": "string",
          "analyzer": "psv_disc_ngram_analyzer"
        },
        "psv_id": {
          "type": "long",
          "include_in_all": false
        },
        "lic_status_desc": {
          "type": "string",
          "include_in_all": false
        },
        "lic_type_desc": {
          "type": "string",
          "include_in_all": false
        }
      }
    }
  },
  "settings": {
    "analysis": {
      "analyzer": {
        "psv_disc_ngram_analyzer": {
          "tokenizer": "psv_disc_ngram_tokenizer",
          "filter": [
            "standard",
            "lowercase",
            "stop"
          ]
        }
      },
      "tokenizer": {
        "psv_disc_ngram_tokenizer": {
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
