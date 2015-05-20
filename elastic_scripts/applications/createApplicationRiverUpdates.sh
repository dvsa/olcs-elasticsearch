db=$1
username=$2
password=$3

sql_script=$(<applications.sql)
escaped_sql=${sql_script//\'/\\\"} 
final_sql=$(echo $escaped_sql | tr '\n' ' ')

curl -XPUT 'localhost:9200/_river/olcs_application_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/'"$db"'",
        "user": "'"$username"'", 
        "password": "'"$password"'", 
        "schedule" : "0 8/10 0-23 ? * *",
        "sql": [{"statement":"update elastic_updates set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"application\""},{"statement":"'"$final_sql"'"}],
        "index": "application_v1",
        "type": "application"
    }  
}'
