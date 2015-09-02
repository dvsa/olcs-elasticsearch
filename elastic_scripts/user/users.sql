SELECT 
    CONCAT_WS('_',
            IFNULL(u.id, 'none'),
            IFNULL(r.id, 'none'),
            IFNULL(o.id, 'none'),
            IFNULL(cd.id, 'none')) AS _id,
    u.id user_id,
    r.id role_id,
    o.id org_id,
    cd.id con_det_id,
    u.pid identity_pid,
    u.last_successful_login_date,
    u.team_id,
    cd.email_address,
    cd.forename,
    cd.family_name,
    t.name team_name,
    o.name org_name,
    CASE
        WHEN
            (r.code LIKE 'CW%' OR r.code = 'ADMIN'
                OR r.code = 'SYS')
        THEN
            'Internal'
        WHEN (r.code = 'LA') THEN 'Local Authority'
        WHEN (r.code LIKE 'PART%') THEN 'Partner'
        WHEN (r.code = 'TM') THEN 'Transport Manager'
        ELSE 'Operator'
    END user_type,
    r.role,
    CASE
        WHEN (u.locked_date IS NOT NULL) THEN 'Yes'
        ELSE 'No'
    END disabled,
    t.name description
FROM
    team t
        INNER JOIN
    user u ON (u.team_id = t.id)
        INNER JOIN
    user_role ur ON (ur.user_id = u.id)
        INNER JOIN
    role r ON (r.id = ur.role_id)
        LEFT JOIN
    organisation_user ou ON (ou.user_id = u.id)
        LEFT JOIN
    organisation o ON (o.id = ou.organisation_id)
        INNER JOIN
    contact_details cd ON (cd.id = u.contact_details_id)
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'user')
WHERE
    (u.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR r.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR cd.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))
        