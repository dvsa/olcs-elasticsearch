#!/bin/bash

db=$1
username=$2
password=$3


sql_script=$(<busreg.sql)
escaped_sql=${sql_script//\'/\\\"} 
final_sql=$(echo $escaped_sql | tr '\n' ' ')

echo $value

curl -XPUT 'localhost:9200/_river/olcs_busreg_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/'"$db"'",
        "user": "'"$username"'", 
        "password": "'"$password"'",
        "schedule" : "0 2/10 0-23 ? * *",
        "sql":[{"statement":"update elastic_updates set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"busreg\""},{"statement":"'"$final_sql"'"}],
        "index": "busreg_v1",
        "type": "busreg"
    }  
}'
