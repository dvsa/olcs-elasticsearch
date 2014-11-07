curl -XPUT 'localhost:9200/_river/olcs_licence_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/olcs",
        "user": "olcs",
        "password": "password",
        "sql":"select concat_ws(\"_\", ifnull(o.id, \"none\"), ifnull(l.id, \"none\"), ifnull(a.id, \"none\"), ifnull(r1.id, \"none\"), ifnull(ta1.id, \"none\")) as _id, l.lic_no,  l.fabs_reference, o.name org_name, lower(o.name) org_name_wildcard, o.company_or_llp_no, if(o.is_mlh=1,\"yes\",\"no\") is_mlh, r1.description org_type_desc, rd_lt.description lic_type_desc, rd_ls.description lic_status_desc, a.postcode correspondence_postcode, a.saon_desc, a.town, (select count(*) from cases where licence_id = l.id) case_count, tn.name trading_name, ta1.name licence_traffic_area, ta2.name lead_tc, o.id org_id, l.id lic_id, a.id addr_id, r1.id ref_data_id, ta1.id ta_id from licence l inner join organisation o ON (l.organisation_id = o.id) inner join ref_data rd_lt on (rd_lt.id = l.licence_type) inner join ref_data rd_ls on (rd_ls.id = l.status) left join (contact_details cd, address a) ON (cd.licence_id = l.id AND cd.contact_type = \"ct_corr\" AND cd.address_id = a.id)  left join ref_data r1 ON (o.type = r1.id) left join trading_name tn ON (l.id = tn.licence_id) inner join traffic_area ta1 ON (l.traffic_area_id = ta1.id) left join traffic_area ta2 ON (o.lead_tc_area_id = ta2.id)",
        "index": "licence_v1",
        "type": "licence"
    }  
}'
