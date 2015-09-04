curl -XPUT 'localhost:9200/address_v1' -d '
{
  "aliases" : {
      "address" : {}
  },
  "mappings": {
    "address": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "address_ngram_analyzer"
      },
      "properties" : {
    	"addr_id" : {
            "type" : "long",
            "include_in_all" : false
          },
        "org_id" : {
            "type" : "long",
            "include_in_all" : false
          },
        "oc_id" : {
            "type" : "long",
            "include_in_all" : false
          },
        "loc_id" : {
            "type" : "long",
            "include_in_all" : false
          },
        "lic_id" : {
            "type" : "long",
            "include_in_all" : false
          },
        "lic_no" : {
            "type" : "string",
            "analyzer" : "address_ngram_analyzer"
          },
          "address_type" : {
              "type" : "string",
              "index" : "not_analyzed"
            }
        "paon_desc" : {
            "type" : "string",
            "analyzer" : "address_ngram_analyzer"
          },
        "saon_desc" : {
            "type" : "string",
            "analyzer" : "address_ngram_analyzer"
          },
        "street" : {
            "type" : "string",
            "analyzer" : "address_ngram_analyzer"
          },
        "locality" : {
            "type" : "string",
            "analyzer" : "address_ngram_analyzer"
          },
        "town" : {
            "type" : "string",
            "analyzer" : "address_ngram_analyzer"
          },
        "postcode" : {
            "type" : "string",
            "analyzer" : "address_edgengram_analyzer"
          },
          "country_code" : {
            "type" : "string"
          },
        "org_name" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "org_name_wildcard" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
        "complaint_case_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "opposition_case_id" : {
              "type" : "long",
              "include_in_all" : false
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
        "address_ngram_analyzer": {
          "tokenizer": "address_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
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
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "address_edgengram_tokenizer": {
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
