db=$1
username=$2
password=$3

curl -XPUT 'localhost:9200/_river/olcs_publication_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/'"$db"'",
        "user": "'"$username"'", 
        "password": "'"$password"'", 
        "schedule" : "0 8/10 0-23 ? * *",
        "sql": [{"statement":"update elastic_updates set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"publications\""},{"statement" : "SELECT concat_ws(\"_\",ifnull(pl.id,\"none\"),ifnull(p.id,\"none\"),ifnull(ta.id,\"none\"),ifnull(ps.id,\"none\")) as _id, pl.id as pub_link_id, p.id as pub_id, ta.id as ta_id, ps.id as pub_sec_id, p.publication_no as pub_no, p.pub_type as pub_type, p.pub_date as pub_date, p.pub_status as pub_status, rd1.description as description, ta.name as ta_name, ps.description as pub_sec_desc FROM publication_link pl INNER JOIN publication p ON pl.publication_id = p.id INNER JOIN traffic_area ta ON p.traffic_area_id = ta.id INNER JOIN publication_section ps ON pl.publication_section_id = ps.id INNER JOIN ref_data rd1 ON p.pub_status = rd1.id inner join elastic_updates eu ON (eu.index_name = \"publications\") where (pl.last_modified_on > from_unixtime(eu.previous_runtime) or p.last_modified_on > from_unixtime(eu.previous_runtime) or ta.last_modified_on > from_unixtime(eu.previous_runtime) or ps.last_modified_on > from_unixtime(eu.previous_runtime))"}],
        "index": "publication_v1",
        "type": "publication"
    }  
}'
