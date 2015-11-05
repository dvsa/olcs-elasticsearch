#!/bin/bash

version=${1:-1}

curl -XPUT 'localhost:9200/busreg_v'$version -d '
{
	
  "mappings": {
    "busreg_v'"$version"'": {
      "_all": {
        "type": "string",
        "null_value": "na",
        "index": "analyzed",
        "analyzer": "busreg_ngram_analyzer"
      },
      "properties" : {
    	"busreg_id" : {
    		"type": "long",
    		"include_in_all" : false
    	},
    	"service_no" : {
    		"type" : "string"
    	},
    	"reg_no" : {
    		"type" : "string",
    		"analyzer" : "busreg_edgengram_analyzer"
    	},
    	"lic_id" : {
    		"type" : "long",
    		"include_in_all" : false
    	},
    	"lic_no" : {
    		"type" : "string",
    		"analyzer" : "busreg_edgengram_analyzer"
    	},
    	"lic_status" : {
    		"type" : "string",
            "index" : "not_analyzed"
    	},
    	"org_name" : {
            "type" : "string",
            "index" : "not_analyzed"
        },
        "org_id" : {
            "type" : "long",
            "include_in_all" : false
        },
        "org_name_wildcard" : {
            "type" : "string",
            "index" : "not_analyzed"
        },
		"start_point" : {
			"type" : "string",
			"include_in_all" : false
		},
		"finish_point" : {
			"type" : "string",
			"include_in_all" : false
		},
		"date_1st_reg" : {
			"type": "date",
                        "format": "yyyy-MM-dd"
		},
		"bus_reg_status" : {
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
		"route_no" : {
			"type" : "integer"
		},
		"variation_no" : {
			"type" : "integer"
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
        "busreg_ngram_analyzer": {
          "tokenizer": "busreg_ngram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"]
        },
        "busreg_edgengram_analyzer": {
          "tokenizer": "busreg_edgengram_tokenizer",
          "filter" : ["standard", "lowercase", "stop"],
          "char_filter" : ["spaces_removed_pattern"]
        }
      },
      "tokenizer": {
        "busreg_ngram_tokenizer": {
          "type": "nGram",
          "min_gram": "4",
          "max_gram": "10",
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "busreg_edgengram_tokenizer": {
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
