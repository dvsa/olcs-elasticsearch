host=$1
db=$2
username=$3
password=$4

sql_script=$(<vehicle_current.sql)
escaped_sql=${sql_script//\'/\\\"} 
final_sql=$(echo $escaped_sql | tr '\n' ' ')

curl -XPUT 'localhost:9200/_river/olcs_vehicle_current_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://'"$host"':3306/'"$db"'",
        "user": "'"$username"'", 
        "password": "'"$password"'", 
        "schedule" : "0 8/10 0-23 ? * *",
        "sql": [{"statement":"update elastic_update set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"vehicle_current\""},{"statement":"'"$final_sql"'"}],
        "index": "vehicle_current_v1",
        "type": "vehicle"
    }  
}'
