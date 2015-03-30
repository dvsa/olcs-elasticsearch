db=$1
username=$2
password=$3

curl -XPUT 'localhost:9200/_river/olcs_vehicle_removed_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/'"$db"'",
        "user": "'"$username"'", 
        "password": "'"$password"'", 
        "sql": "select concat_ws(\"_\",ifnull(v.id,\"none\"),ifnull(l.id,\"none\"),ifnull(lv.id,\"none\"),ifnull(o.id,\"none\"),ifnull(gd.id,\"none\")) as _id, r1.description lic_type_desc, l.lic_no, (select description from ref_data where l.status=id) as lic_status_desc, v.vrm, o.name org_name, lower(o.name) org_name_wildcard, gd.disc_no disc_no, lv.removal_date, lv.specified_date, r1.id ref_data_id, l.id lic_id, lv.id lic_veh_id, v.id veh_id, o.id org_id, gd.id gd_id from licence l inner join ref_data r1 ON (l.goods_or_psv = r1.id) inner join licence_vehicle lv ON (l.id = lv.licence_id) inner join vehicle v ON (lv.vehicle_id = v.id) inner join organisation o ON (l.organisation_id = o.id) left join goods_disc gd ON (lv.id = gd.licence_vehicle_id) where lv.removal_date is not null",
        "index": "vehicle_removed_v1",
        "type": "vehicle"
    }  
}'
