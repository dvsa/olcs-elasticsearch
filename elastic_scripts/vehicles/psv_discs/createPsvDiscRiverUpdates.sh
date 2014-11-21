curl -XPUT 'localhost:9200/_river/olcs_psv_disc_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/olcs",   
        "user": "olcs", 
        "password": "password",
        "schedule" : "0 6/10 0-23 ? * *",
        "sql": [{"statement":"update elastic_updates set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"psv_disc\""},{"statement" : "select concat_ws(\"_\",ifnull(l.id,\"none\"),ifnull(o.id,\"none\"),ifnull(psv.id,\"none\")) as _id, r1.description lic_type_desc, l.lic_no, (select description from ref_data where l.status=id) as lic_status_desc, o.name org_name, lower(o.name) org_name_wildcard, psv.disc_no disc_no, l.id lic_id, o.id org_id, psv.id psv_id from licence l left join ref_data r1 ON (l.goods_or_psv = r1.id) inner join organisation o ON (l.organisation_id = o.id) left join psv_disc psv ON (l.id = psv.licence_id) inner join elastic_updates eu ON (eu.index_name = \"psv_disc\") where (o.last_modified_on > from_unixtime(eu.previous_runtime) or psv.last_modified_on > from_unixtime(eu.previous_runtime) or l.last_modified_on > from_unixtime(eu.previous_runtime))"}],
        "index": "psv_disc_v1",
        "type": "psv_disc"
    }  
}'
