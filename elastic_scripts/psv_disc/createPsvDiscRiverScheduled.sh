host=$1
db=$2
username=$3
password=$4
version=${5:-1}

sql_script=$(<psv_disc.sql)
escaped_sql=${sql_script//\'/\\\"} 
final_sql=$(echo $escaped_sql | tr '\n' ' ')

curl -XPUT 'localhost:9200/_river/olcs_psv_disc_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://'"$host"':3306/'"$db"'",
        "user": "'"$username"'", 
        "password": "'"$password"'", 
        "schedule" : "0 8/10 0-23 ? * *",
        "sql": [{"statement":"update elastic_update set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"psv_disc\""},{"statement":"'"$final_sql"'"}],
        "index": "psv_disc_v'"$version"'",
        "type": "psv_disc"
    }  
}'
