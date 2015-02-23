
curl -XPUT 'localhost:9200/_river/olcs_busreg_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/olcsetl",
        "user": "olcsetl",
        "password": "password",
        "schedule" : "0 2/10 0-23 ? * *",
        "sql":"SELECT concat_ws(\"_\", ifnull(br1.id, \"none\"), ifnull(lic.id, \"none\"), ifnull(org.id, \"none\"),ifnull(lic.status, \"none\"), ifnull(br1.status, \"none\")) as _id, br1.id AS busreg_id,IFNULL(CONCAT(br1.service_no, \"(\",(SELECT GROUP_CONCAT(COALESCE(service_no,\"NULL\"),\"\") AS other FROM bus_reg_other_service WHERE bus_reg_id = br1.id),\")\"), br1.service_no) as service_no,br1.reg_no AS reg_no,lic.id AS lic_id,lic.lic_no AS lic_no,rd_lic_status.description AS lic_status,org.name AS organisation_name,br1.start_point AS start_point,br1.finish_point AS finish_point,\"2015-01-01\" AS date_1st_reg,CASE WHEN br1.status = \"breg_s_registered\" And end_date <= Now() THEN \"Expired\" ELSE rd_bus_status.description END as bus_reg_status,br1.route_no,br1.variation_no FROM bus_reg AS br1 INNER JOIN licence lic ON lic.id = br1.licence_id INNER JOIN organisation AS org ON org.id = lic.organisation_ID INNER JOIN ref_data AS rd_lic_status ON (rd_lic_status.id = lic.status) INNER JOIN ref_data AS rd_bus_status ON (rd_bus_status.id = br1.status) WHERE br1.variation_no = coalesce((SELECT MAX(variation_no) FROM bus_reg br2 WHERE (br2.reg_no = br1.reg_no AND br2.status NOT IN(\"breg_s_refused\",\"breg_s_withdrawn\") AND (br2.end_date is null or br2.end_date > Now()))),0)",
        "index": "busreg_v1",
        "type": "busreg"
    }  
}'


curl -XPUT 'localhost:9200/_river/olcs_application_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/${db}",
        "user": "${username}",
        "password": "${password}",
        "schedule" : "0 2/10 0-23 ? * *",
        "sql": [{"statement":"update elastic_updates set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"application\""},{"statement" : "select concat_ws(\"_\", ifnull(o.id, \"none\"), ifnull(l.id, \"none\"), ifnull(a.id, \"none\"), ifnull(ad.id, \"none\")) as _id, a.id app_id, l.id lic_id, l.lic_no, o.id org_id, o.name org_name, lower(o.name) org_name_wildcard, ad.postcode correspondence_postcode, a.tot_auth_vehicles, a.tot_auth_trailers, a.received_date, rd_lt.description lic_type_desc, rd_ls.description lic_status_desc, rd_as.description app_status_desc from application a inner join licence l on (a.licence_id = l.id) inner join organisation o on (l.organisation_id = o.id) left join (contact_details cd, address ad) on (cd.licence_id = l.id and cd.Contact_Type = \"ct_corr\" and cd.address_id = ad.id) inner join ref_data rd_lt on (rd_lt.id = l.licence_type) inner join ref_data rd_ls on (rd_ls.id = l.status) inner join ref_data rd_as on (rd_as.id = a.status) inner join elastic_updates eu ON (eu.index_name = \"application\") where (ad.last_modified_on > from_unixtime(eu.previous_runtime) or a.last_modified_on > from_unixtime(eu.previous_runtime) or l.last_modified_on > from_unixtime(eu.previous_runtime) or o.last_modified_on > from_unixtime(eu.previous_runtime))"}],
        "index": "application_v1",
        "type": "application"
    }  
}'
