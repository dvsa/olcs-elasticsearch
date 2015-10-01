host=$1
db=$2
username=$3
password=$4

sql_script=$(<recipient.sql)
escaped_sql=${sql_script//\'/\\\"}
final_sql=$(echo $escaped_sql | tr '\n' ' ')

curl -XPUT 'localhost:9200/_river/olcs_recipient_river/_meta' -d '{
    "type": "jdbc",
    "jdbc": {
        "driver": "com.mysql.jdbc.Driver",
        "url": "jdbc:mysql://'"$host"':3306/'"$db"'",
        "user": "'"$username"'",
        "password": "'"$password"'",
        "sql": [{"statement":"update elastic_update set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"recipient\""},{"statement":"'"$final_sql"'"}],
        "index": "recipient_v1",
        "type": "recipient"
    }
}'
