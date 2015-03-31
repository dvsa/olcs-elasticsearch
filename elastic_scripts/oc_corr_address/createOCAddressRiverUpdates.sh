db=$1
username=$2
password=$3

curl -XPUT 'localhost:9200/_river/olcs_address_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/'"$db"'",
        "user": "'"$username"'", 
        "password": "'"$password"'",
        "schedule" : "0 3/10 0-23 ? * *",
        "sql": [{"statement":"update elastic_updates set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"addresses\""},{"statement" : "SELECT concat_ws(\"_\",ifnull(addr.id,\"none\"),ifnull(app.id,\"none\"),ifnull(org.id,\"none\"),ifnull(oc.id,\"none\"),ifnull(aoc.id,\"none\"),ifnull(lic.id,\"none\")) as _id, addr.id addr_id, app.id as app_id, org.id as org_id, oc.id as oc_id, aoc.id as aoc_id, lic.id as lic_id, lic.lic_no as lic_no, addr.paon_desc as paon_desc, addr.saon_desc as saon_desc, addr.street as street, addr.locality as locality, addr.town as town, addr.postcode as postcode, addr.country_code as cc, (select description from ref_data where id = app.status) as app_status, (select description from ref_data where id = lic.status) as lic_status, (select description from ref_data where id = lic.licence_type) as lic_type, lic.lic_no as lic_no, org.name org_name, LOWER(org.name) org_name_wildcard,, (SELECT count( oco.operating_centre_id) as count FROM operating_centre_opposition oco WHERE (oco.operating_centre_id = oc.id)) AS oc_opposition_count FROM address addr INNER JOIN operating_centre oc ON addr.id = oc.address_id INNER JOIN application_operating_centre aoc ON oc.id = aoc.operating_centre_id INNER JOIN application app ON aoc.application_id = app.id INNER JOIN licence lic ON app.licence_id = lic.id INNER JOIN organisation org ON lic.organisation_id = org.id inner join elastic_updates eu ON (eu.index_name = \"addresses\") where (addr.last_modified_on > from_unixtime(eu.previous_runtime) or app.last_modified_on > from_unixtime(eu.previous_runtime) or org.last_modified_on > from_unixtime(eu.previous_runtime) or oc.last_modified_on > from_unixtime(eu.previous_runtime) or aoc.last_modified_on > from_unixtime(eu.previous_runtime) or lic.last_modified_on > from_unixtime(eu.previous_runtime))"}],
        "index": "address_v1",
        "type": "address"
    }  
}'
