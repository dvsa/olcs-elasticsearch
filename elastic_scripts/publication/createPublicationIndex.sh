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
          "include_in_all": false
        },
        "pub_date": {
          "type": "date",
          "format": "dateOptionalTime",
          "include_in_all": false
        },
        "pub_status": {
          "type": "string",
          "analyzer": "publication_ngram_analyzer"
        },
        "description": {
          "type": "string",
          "analyzer": "publication_ngram_analyzer"
        },
        "ta_name": {
          "type": "string",
          "analyzer": "publication_ngram_analyzer"
        },
        "pub_sec_desc": {
          "type": "string",
          "analyzer": "publication_ngram_analyzer"
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
