curl -XPUT 'localhost:9200/_river/olcs_vehicle_current_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/olcs",
        "user": "olcs", 
        "password": "password", 
        "schedule" : "0 8/10 0-23 ? * *",
        "sql": [{"statement":"update elastic_updates set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"vehicle_current\""},{"statement" : "select concat_ws(\"_\",ifnull(v.id,\"none\"),ifnull(l.id,\"none\"),ifnull(lv.id,\"none\"),ifnull(o.id,\"none\"),ifnull(gd.id,\"none\")) as _id, r1.description lic_type_desc, l.lic_no, (select description from ref_data where l.status=id) as lic_status_desc, v.vrm, o.name org_name, lower(o.name) org_name_wildcard, gd.disc_no disc_no, lv.removal_date, lv.specified_date, r1.id ref_data_id, l.id lic_id, lv.id lic_veh_id, v.id veh_id, o.id org_id, gd.id gd_id from licence l inner join ref_data r1 ON (l.goods_or_psv = r1.id) inner join licence_vehicle lv ON (l.id = lv.licence_id) inner join vehicle v ON (lv.vehicle_id = v.id) inner join organisation o ON (l.organisation_id = o.id) left join goods_disc gd ON (lv.id = gd.licence_vehicle_id) inner join elastic_updates eu ON (eu.index_name = \"vehicle_current\") where ((v.last_modified_on > from_unixtime(eu.previous_runtime) or l.last_modified_on > from_unixtime(eu.previous_runtime) or lv.last_modified_on > from_unixtime(eu.previous_runtime) or o.last_modified_on > from_unixtime(eu.previous_runtime) or gd.last_modified_on > from_unixtime(eu.previous_runtime)) and lv.removal_date is null )"}],
        "index": "vehicle_current_v1",
        "type": "vehicle"
    }  
}'
