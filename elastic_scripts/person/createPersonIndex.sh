curl -XPUT 'localhost:9200/person_v1' -d '
{
  "aliases" : {
      "person" : {}
  },
  "mappings": {
    "person": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "person_ngram_analyzer"
      },
      "properties" : {
          "person_id" : {
            "type" : "long"
          },
        "org_id" : {
            "type" : "long"
          },
        "lic_id" : {
            "type" : "long"
          },
        "tm_id" : {
            "type" : "long"
          },
        "contact_type" : {
            "type" : "string"
          },
        "person_forename" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
        "person_forename_wildcard" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
        "person_family_name" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
        "person_family_name_wildcard" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
         "person_birth_date" : {
              "type": "date",
              "format": "yyyy-MM-dd"
         },
         "person_other_name" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
         "person_other_name_wildcard" : {
            "type" : "string",
            "index" : "not_analyzed"
          },
         "person_birth_place" : {
            "type" : "string",
            "analyzer" : "person_ngram_analyzer"
         },
         "person_title" : {
              "type" : "string"
         },
         "person_deleted" : {
                "type": "date",
                "format": "yyyy-MM-dd"
         },
         "person_created_on" : {
                "type": "date",
                "format": "yyyy-MM-dd"
         },
           "org_name" : {
             "type" : "string",
             "index" : "not_analyzed"
         },
         "org_name_wildcard" : {
             "type" : "string",
             "index" : "not_analyzed"
         },
         "lic_no" : {
             "type" : "string",
             "analyzer" : "person_ngram_analyzer"
         },
         "lic_status_desc" : {
             "type" : "string",
             "index" : "not_analyzed"
           },
         "lic_type_desc" : {
               "type" : "string",
               "index" : "not_analyzed"
          },
          "traffic_area" : {
              "type" : "string",
              "index" : "not_analyzed"
         },
         "ta_code" : {
             "type" : "string",
             "index" : "not_analyzed"
        },
          "tm_status_desc" : {
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
        "person_ngram_analyzer": {
          "tokenizer": "person_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        },
        "person_edgengram_analyzer": {
          "tokenizer": "person_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "person_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "person_edgengram_tokenizer": {
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
