curl -XPUT 'localhost:9200/case_suggester_v1' -d '
{
  "aliases" : {
      "case_suggester" : {}
  },
  "mappings": {
    "case_suggester": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "case_suggester_ngram_analyzer"
      },
  "properties": {
    "app_id": {
      "include_in_all": "false",
      "type": "long"
    },
    "case_id": {
      "include_in_all": "false",
      "type": "long"
    },
    "case_type_desc": {
      "analyzer": "case_suggester_ngram_analyzer",
      "type": "string"
    },
    "close_date": {
      "type": "date",
      "format": "dateOptionalTime"
    },
    "lic_corr_postcode": {
      "type": "completion",
      "index_analyzer" : "simple",
      "search_analyzer" : "simple",
      "payloads" : true 
    },
    "lic_id": {
      "include_in_all": "false",
      "type": "long"
    },
    "lic_no": {
      "analyzer": "case_suggester_ngram_analyzer",
      "type": "string"
    },
    "open_date": {
      "type": "date",
      "format": "dateOptionalTime"
    },
    "org_id": {
      "include_in_all": "false",
      "type": "long"
    },
    "org_name": {
      "analyzer": "case_suggester_ngram_analyzer",
      "type": "string"
    },
    "postcode": {
      "type": "completion",
      "index_analyzer" : "simple",
      "search_analyzer" : "simple",
      "payloads" : true 
    },
    "tm_family_name": {
      "analyzer": "case_suggester_ngram_analyzer",
      "type": "string"
    },
    "tm_forename": {
      "analyzer": "case_suggester_ngram_analyzer",
      "type": "string"
    },
    "tm_id": {
      "include_in_all": "false",
      "type": "long"
    }
  }
    }
  },
  "settings": {
    "analysis": {
      "analyzer": {
        "case_suggester_ngram_analyzer": {
          "tokenizer": "case_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        }
      },
      "tokenizer": {
        "case_ngram_tokenizer": {
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
