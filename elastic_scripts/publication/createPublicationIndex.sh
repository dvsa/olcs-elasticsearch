curl -XPUT 'localhost:9200/publication_v1' -d '
{
  "aliases": {
    "publication": {}
  },
  "mappings": {
    "publication": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "publication_ngram_analyzer"
      },
      "properties": {        
        "pub_link_id": {
          "type": "long",
          "include_in_all": false
        },
        "pub_id": {
          "type": "long",
          "include_in_all": false
        },
        "lic_id": {
            "type": "long",
            "include_in_all": false
          },
          "org_id": {
              "type": "long",
              "include_in_all": false
            },
        "ta_id": {
          "type": "string",
          "include_in_all": false
        },
        "pub_sec_id": {
          "type": "long",
          "include_in_all": false
        },
        "pub_no": {
          "type": "long",
          "include_in_all": false
        },
        "pub_type": {
          "type": "string",
          "index" : "not_analyzed"
        },
        "pub_date": {
          "type": "date",
          "format": "yyyy-MM-dd",
          "include_in_all": false
        },
        "pub_status": {
          "type": "string",
          "index" : "not_analyzed"
        },
        "pub_status_desc": {
          "type": "string",
          "index" : "not_analyzed"
        },
        "lic_no" : {
            "type" : "string",
            "analyzer" : "publication_ngram_analyzer"
          },
          "lic_type_desc" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
          "org_name" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "org_name_wildcard" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
        "traffic_area": {
          "type": "string",
          "index" : "not_analyzed"
        },
        "pub_sec_desc": {
          "type": "string",
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
        "publication_ngram_analyzer": {
          "tokenizer": "publication_ngram_tokenizer",
          "filter": [
            "standard",
            "lowercase",
            "stop"
          ]
        },
        "publication_edgengram_analyzer": {
          "tokenizer": "publication_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "publication_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
      "publication_edgengram_tokenizer": {
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
