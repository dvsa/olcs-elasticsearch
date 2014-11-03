curl -XPUT 'localhost:9200/_river/olcs_psv_disc_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/olcs",   
        "user": "olcs", 
        "password": "password", 
        "sql":"select concat_ws(\"_\",ifnull(l.id,\"none\"),ifnull(o.id,\"none\"),ifnull(psv.id,\"none\")) as _id, r1.description lic_type_desc, l.lic_no, (select description from ref_data where l.status=id) as lic_status_desc, o.name org_name, psv.disc_no disc_no, l.id lic_id, o.id org_id, psv.id psv_id from licence l left join ref_data r1 ON (l.goods_or_psv = r1.id) inner join organisation o ON (l.organisation_id = o.id) left join psv_disc psv ON (l.id = psv.licence_id)",
        "index": "psv_disc_v1",
        "type": "psv_disc"
    }  
}'
