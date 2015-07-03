SELECT 
    CONCAT_WS('_',
            IFNULL(p.id, 'none'),
            IFNULL(o.id, 'none'),
            IFNULL(l.id, 'none')) AS _id,
    p.id person_id,
    o.id org_id,
    l.id lic_id,
    cd.contact_type AS contact_type,
    p.forename AS person_forename,
    LOWER(p.forename) AS person_forename_wildcard,
    p.family_name AS person_family_name,
    LOWER(p.family_name) AS person_family_name_wildcard,
    case when p.birth_date is not null then DATE_FORMAT(p.birth_date, '%Y-%m-%d') else now() end person_birth_date,
    p.other_name person_other_name,
    p.birth_place person_birth_place,
    p.title person_title,
    DATE_FORMAT(p.deleted_date, '%Y-%m-%d') person_deleted,
    DATE_FORMAT(p.created_on, '%Y-%m-%d') person_created_on,
    o.name org_name,
    LOWER(o.name) AS org_name_wildcard,
    l.lic_no lic_no,
    rd_lic_type.description lic_type_desc,
    rd_lic_status.description lic_status_desc,
    tm.id tm_id,
    rd_tm_status.description tm_status_desc
FROM
    transport_manager tm
        INNER JOIN
    contact_details cd ON (tm.home_cd_id = cd.id)
        INNER JOIN
    person p ON cd.person_id = p.id
        LEFT JOIN
    transport_manager_licence tml ON (tml.transport_manager_id = tm.id)
        LEFT JOIN
    (licence l, organisation o, ref_data rd_lic_type, ref_data rd_lic_status) ON (o.id = l.organisation_id
        AND l.id = tml.licence_id
        AND rd_lic_type.id = l.licence_type
        AND rd_lic_status.id = l.status)
        INNER JOIN
    ref_data rd_tm_status ON (rd_tm_status.id = tm.tm_status)
        INNER JOIN
    elastic_updates eu ON (eu.index_name = 'people')
WHERE
    (p.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR l.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)) 
UNION ALL SELECT 
    CONCAT_WS('_',
            IFNULL(p.id, 'none'),
            IFNULL(o.id, 'none'),
            IFNULL(l.id, 'none')) AS _id,
    p.id person_id,
    o.id org_id,
    l.id lic_id,
    NULL AS contact_type,
    p.forename AS person_forename,
    LOWER(p.forename) AS person_forename_wildcard,
    p.family_name AS person_family_name,
    LOWER(p.family_name) AS person_family_name_wildcard,
    case when p.birth_date is not null then DATE_FORMAT(p.birth_date, '%Y-%m-%d') else now() end person_birth_date,
    p.other_name person_other_name,
    p.birth_place person_birth_place,
    p.title person_title,
    DATE_FORMAT(p.deleted_date, '%Y-%m-%d') person_deleted,
    DATE_FORMAT(p.created_on, '%Y-%m-%d') person_created_on,
    o.name org_name,
    LOWER(o.name) AS org_name_wildcard,
    l.lic_no lic_no,
    rd_lic_type.description lic_type_desc,
    rd_lic_status.description lic_status_desc,
    null tm_id,
    null tm_status_desc
FROM
    person p
        INNER JOIN
    organisation_person op ON (op.person_id = p.id)
        INNER JOIN
    organisation o ON (o.id = op.organisation_id)
        LEFT JOIN
    licence l ON (l.organisation_id = o.id)
        INNER JOIN
    ref_data rd_lic_type ON (rd_lic_type.id = l.licence_type)
        INNER JOIN
    ref_data rd_lic_status ON (rd_lic_status.id = l.status)
        INNER JOIN
    elastic_updates eu ON (eu.index_name = 'people')
WHERE
    (p.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR l.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))