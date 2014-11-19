curl -XPUT 'localhost:9200/_river/olcs_application_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/olcs",
        "user": "olcs",
        "password": "password",
        "schedule" : "0 2/10 0-23 ? * *",
        "sql": [{"statement":"update elastic_updates set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"application\""},{"statement" : "select concat_ws(\"_\", ifnull(o.id, \"none\"), ifnull(l.id, \"none\"), ifnull(a.id, \"none\"), ifnull(ad.id, \"none\")) as _id, a.id app_id, l.id lic_id, l.lic_no, o.id org_id, o.name org_name, lower(o.name) org_name_wildcard, ad.postcode correspondence_postcode, a.tot_auth_vehicles, a.tot_auth_trailers, a.received_date, rd_lt.description lic_type_desc, rd_ls.description lic_status_desc, rd_as.description app_status_desc from application a inner join licence l on (a.licence_id = l.id) inner join organisation o on (l.organisation_id = o.id) left join (contact_details cd, address ad) on (cd.licence_id = l.id and cd.Contact_Type = \"ct_corr\" and cd.address_id = ad.id) inner join ref_data rd_lt on (rd_lt.id = l.licence_type) inner join ref_data rd_ls on (rd_ls.id = l.status) inner join ref_data rd_as on (rd_as.id = a.status) inner join elastic_updates eu ON (eu.index_name = \"application\") where (ad.last_modified_on > from_unixtime(eu.previous_runtime) or a.last_modified_on > from_unixtime(eu.previous_runtime) or l.last_modified_on > from_unixtime(eu.previous_runtime) or o.last_modified_on > from_unixtime(eu.previous_runtime))"}],
        "index": "application_v1",
        "type": "application"
    }  
}'
