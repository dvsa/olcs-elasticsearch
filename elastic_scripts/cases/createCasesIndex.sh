curl -XPUT 'localhost:9200/case_v1' -d '
{
  "aliases" : {
      "case" : {}
  },
  "mappings": {
    "case": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "case_ngram_analyzer"
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
    "app_status_desc": {
      "analyzer": "case_ngram_analyzer",
      "type": "string"
    },
    "lic_status_desc": {
      "analyzer": "case_ngram_analyzer",
      "type": "string"
    },
    "case_type_desc": {
      "analyzer": "case_ngram_analyzer",
      "type": "string"
    },
    "correspondence_postcode": {
      "analyzer": "case_edgengram_analyzer",
      "type": "string"
    },
    "lic_id": {
      "include_in_all": "false",
      "type": "long"
    },
    "lic_no": {
      "analyzer": "case_ngram_analyzer",
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
      "type": "string",
      "index" : "not_analyzed"
    },
    "org_name_wildcard": {
      "type": "string",
      "index" : "not_analyzed"
    },
    "tm_family_name": {
      "analyzer": "case_ngram_analyzer",
      "type": "string"
    },
    "tm_forename": {
      "analyzer": "case_ngram_analyzer",
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
      "char_filter" : {
        "spaces_removed_pattern":{
          "type":"pattern_replace",
          "pattern":"\\s",
          "replacement":""
        } 
      },
      "analyzer": {
        "case_ngram_analyzer": {
          "tokenizer": "case_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        },
        "case_edgengram_analyzer": {
          "tokenizer": "case_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"] 
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
        },
        "case_edgengram_tokenizer": {
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
