curl -XPUT 'localhost:9200/_river/olcs_case_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/olcsdev",
        "user": "olcsdev",
        "password": "password",
        "schedule" : "0 0/10 0-23 ? * *",
        "sql": [{"statement":"update elastic_updates set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"case\""},{"statement" : "select concat_ws(\"_\",ifnull(c.id, \"none\"),ifnull(rd_ct.id, \"none\"),ifnull(l.id, \"none\"),ifnull(o.id, \"none\"),ifnull(tm.id, \"none\"),ifnull(p_tm.id, \"none\"),ifnull(cd_tm.id, \"none\"),ifnull(a_lic.id, \"none\")) as _id,c.id case_id,l.id lic_id,l.lic_no,tm.id tm_id,c.application_id app_id,o.id org_id,o.name org_name,lower(o.name) org_name_wildcard,a_lic.postcode correspondence_postcode,rd_ct.description case_type_desc,c.description case_status_desc,rd_ls.description lic_status_desc,rd_as.description app_status_desc,p_tm.forename tm_forename,p_tm.family_name tm_family_name,c.open_date from cases c left join (application a, ref_data rd_as) ON (a.id = c.application_id and a.status = rd_as.id) inner join ref_data rd_ct ON (rd_ct.id = c.case_type) left join (licence l, organisation o, contact_details cd_lic, address a_lic, ref_data rd_ls) ON (c.licence_id = l.id and o.id = l.organisation_id and cd_lic.contact_type = \"ct_corr\" and (cd_lic.id = l.correspondence_cd_id or cd_lic.id = l.establishment_cd_id or cd_lic.id = l.transport_consultant_cd_id) and cd_lic.address_id = a_lic.id and rd_ls.id = l.status) left join (transport_manager tm, contact_details cd_tm, person p_tm) ON (tm.id = c.transport_manager_id and (cd_tm.id = tm.home_cd_id) and p_tm.id = cd_tm.person_id) inner join elastic_updates eu on (eu.index_name = \"case\") where (c.last_modified_on > from_unixtime(eu.previous_runtime) or a.last_modified_on > from_unixtime(eu.previous_runtime) or l.last_modified_on > from_unixtime(eu.previous_runtime) or o.last_modified_on > from_unixtime(eu.previous_runtime) or cd_lic.last_modified_on > from_unixtime(eu.previous_runtime) or a_lic.last_modified_on > from_unixtime(eu.previous_runtime) or tm.last_modified_on > from_unixtime(eu.previous_runtime) or p_tm.last_modified_on > from_unixtime(eu.previous_runtime))"}],
        "index": "case_v1",
        "type": "case"
    }  
}'
