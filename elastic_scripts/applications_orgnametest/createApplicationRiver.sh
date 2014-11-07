curl -XPUT 'localhost:9200/_river/olcs_application_orgnametest_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/olcs",
        "user": "olcs",
        "password": "password",
        "sql":"select concat_ws(\"_\", ifnull(o.id, \"none\"), ifnull(l.id, \"none\"), ifnull(a.id, \"none\"), ifnull(ad.id, \"none\")) as _id, a.id app_id, l.id lic_id, l.lic_no, o.id org_id, o.name org_name, lower(o.name) org_name_wildcard, ad.postcode correspondence_postcode, a.tot_auth_vehicles, a.tot_auth_trailers, a.received_date, rd_lt.description lic_type_desc, rd_ls.description lic_status_desc, rd_as.description app_status_desc from application a inner join licence l on (a.licence_id = l.id) inner join organisation o on (l.organisation_id = o.id) left join (contact_details cd, address ad) on (cd.licence_id = l.id and cd.Contact_Type = \"ct_corr\" and cd.address_id = ad.id) inner join ref_data rd_lt on (rd_lt.id = l.licence_type) inner join ref_data rd_ls on (rd_ls.id = l.status) inner join ref_data rd_as on (rd_as.id = a.status)",
        "index": "applicationorgnametest_v1",
        "type": "applicationorgnametest"
    }  
}'