#!/bin/bash

curl -XGET 'localhost:9200/application/_analyze?analyzer=standard&pretty' -d 'Under Consideration'
curl -XGET 'localhost:9200/application/_analyze?pretty' -d 'Under Consideration'
curl -XGET 'localhost:9200/application/_analyze?field=app_status_desc&pretty' -d 'Under Consideration'
curl -XGET 'localhost:9200/application/_analyze?field=org_name_wildcard&pretty' -d 'Under Consideration'
curl -XGET 'localhost:9200/application/_analyze?text=Under+Consideration&field=correspondence_postcode&pretty'
