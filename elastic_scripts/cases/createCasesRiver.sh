curl -XPUT 'localhost:9200/_river/olcs_case_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/olcs",
        "user": "olcs",
        "password": "password",
        "sql": "select concat_ws(\"_\", ifnull(c.id, \"none\"), ifnull(rd_ct.id, \"none\"), ifnull(l.id, \"none\"), ifnull(o.id, \"none\"), ifnull(tm.id, \"none\"), ifnull(p_tm.id, \"none\"), ifnull(cd_tm.id, \"none\"), ifnull(a_lic.id, \"none\")) as _id,c.id case_id, l.id lic_id, l.lic_no, tm.id tm_id, c.application_id app_id, o.id org_id, o.name org_name, a_lic.postcode correspondence_postcode, rd_ct.description case_type_desc, p_tm.forename tm_forename, p_tm.family_name tm_family_name, c.open_date, c.close_date from cases c inner join ref_data rd_ct on (rd_ct.id = c.case_type) left join (licence l, organisation o, contact_details cd_lic, address a_lic) on (c.licence_id = l.id and o.id = l.organisation_id and cd_lic.contact_type = \"ct_corr\" and cd_lic.licence_id = l.id and cd_lic.address_id = a_lic.id) left join (transport_manager tm, contact_details cd_tm, person p_tm) on (tm.id = c.transport_manager_id and cd_tm.id = tm.contact_details_id and p_tm.id = cd_tm.person_id)",
        "index": "case_v1",
        "type": "case"
    }  
}'
