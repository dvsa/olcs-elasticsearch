#!/bin/bash

host=$1
db=$2
username=$3
password=$4
index=$5
version=${6:-1}
# schedule defaults to null which means it will execute immediately and only once.
# It can be set to a cron style schedule - we are limiting it to starts at/frequency.
# E.g 2/10 Starts at 2 minutes past the hour and then every 10 minutes thereafter.
schedule=${7:-''}

if [ "$#" -lt 5 ]; then
    echo "Parameters must include <host> <db> <username> <password> <index> <version - optional - default 1> <schedule - optional - default immediate>"
    exit 1
fi

if [ -z "$ELASTIC_HOST" ]
then
    ELASTIC_HOST="localhost"
fi

sql_script=$(<$index.sql)
escaped_sql=${sql_script//\'/\\\"}
final_sql=$(echo $escaped_sql | tr '\n' ' ')

if [ -z $schedule ]
then

curl -XPUT $ELASTIC_HOST':9200/_river/olcs_'"$index"'_river/_meta' -d '{
    "type": "jdbc",
    "jdbc": {
        "driver": "com.mysql.jdbc.Driver",
        "url": "jdbc:mysql://'"$host"':3306/'"$db"'",
        "user": "'"$username"'",
        "password": "'"$password"'",
        "sql":[{"statement":"update elastic_update set previous_runtime=0, runtime=unix_timestamp(now()) where index_name = \"'"$index"'\""},{"statement":"'"$final_sql"'"}],
        "index": "'"$index"'_v'"$version"'",
        "type": "'"$index"'"
    }
}'

else

curl -XPUT $ELASTIC_HOST':9200/_river/olcs_'"$index"'_river/_meta' -d '{
    "type": "jdbc",
    "jdbc": {
        "driver": "com.mysql.jdbc.Driver",
        "url": "jdbc:mysql://'"$host"':3306/'"$db"'",
        "user": "'"$username"'",
        "password": "'"$password"'",
        "schedule" : "0 '"$schedule"' 0-23 ? * *",
        "sql":[{"statement":"update elastic_update set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"'"$index"'\""},{"statement":"'"$final_sql"'"}],
        "index": "'"$index"'_v'"$version"'",
        "type": "'"$index"'"
    }
}'

fi
