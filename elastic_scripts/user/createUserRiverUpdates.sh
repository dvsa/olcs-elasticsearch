db=$0
username=$1
password=$2

curl -XPUT 'localhost:9200/_river/olcs_user_river/_meta' -d '{ 
    "type": "jdbc", 
    "jdbc": {       
        "driver": "com.mysql.jdbc.Driver",  
        "url": "jdbc:mysql://localhost:3306/${db}",
        "user": "${username}",
        "password": "${password}",
        "schedule" : "0 2/10 0-23 ? * *",
        "sql": [{"statement":"update elastic_updates set previous_runtime=runtime, runtime=unix_timestamp(now()) where index_name = \"user\""},{"statement" : "select concat_ws('_', ifnull(u.id, 'none'), ifnull(r.id, 'none'), ifnull(o.id, 'none'), ifnull(cd.id, 'none')) as _id, u.id user_id, r.id role_id, o.id org_id, cd.id con_det_id, u.pid identity_pid,  u.last_successful_login_date, u.team_id, cd.email_address, cd.forename, cd.family_name, t.name team_name, o.name org_name, lower(o.name) org_name_wildcard, case when (u.team_id is not null) then \"Internal\" when (u.local_authority_id is not null) then \"Local Authority\" when (u.partner_contact_details_id is not null) then \"Partner\" when (u.transport_manager_id is not null) then \"Transport Manager\" else \"Operator\" end user_type, r.role, case when (u.locked_date is not null) then \"Yes\" else \"No\" end disabled, t.name description, from team t inner join user u on (u.team_id=t.id) inner join user_role ur on (ur.user_id=u.id) inner join role r on (r.id=ur.role_id) inner join organisation_user ou on (ou.user_id = u.id) inner join organisation o on (o.id = ou.organisation_id) inner join contact_details cd on (cd.id = u.contact_details_id) inner join elastic_updates eu ON (eu.index_name = \"user\") where (u.last_modified_on > from_unixtime(eu.previous_runtime) or r.last_modified_on > from_unixtime(eu.previous_runtime) or o.last_modified_on > from_unixtime(eu.previous_runtime) or cd.last_modified_on > from_unixtime(eu.previous_runtime))"}],
        "index": "user_v1",
        "type": "user"
    }  
}'
