curl -XPUT 'localhost:9200/irfo_v1' -d '
{
  "aliases" : {
      "irfo" : {}
  },
  "mappings": {
    "irfo": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "irfo_ngram_analyzer"
      },
      "properties" : {
          "org_id" : {
            "type" : "long",
            "include_in_all" : false
          },
          "org_name" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "org_name_wildcard" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
            "org_type_desc" : {
                "type" : "string",
                "index" : "not_analyzed"
              },
          "irfo_status" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
    	 "irfo_status_desc" : {
            "type" : "string",
            "index" : "not_analyzed"
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
        "irfo_ngram_analyzer": {
          "tokenizer": "irfo_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        },
        "irfo_edgengram_analyzer": {
          "tokenizer": "irfo_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "irfo_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "irfo_edgengram_tokenizer": {
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
