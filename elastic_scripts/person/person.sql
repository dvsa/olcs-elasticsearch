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
    DATE_FORMAT(p.birth_date, '%Y-%m-%d') person_birth_date,
    p.other_name person_other_name,
    p.birth_place person_birth_place,
    p.title person_title,
    DATE_FORMAT(p.deleted_date, '%Y-%m-%d') person_deleted,
    DATE_FORMAT(p.created_on, '%Y-%m-%d') person_created_on,
    o.name org_name,
    LOWER(o.name) AS org_name_wildcard,
    rd_org_type.description org_type,
    l.lic_no lic_no,
    rd_lic_type.description lic_type_desc,
    rd_lic_status.description lic_status_desc,
    tm.id tm_id,
    rd_tm_status.description tm_status_desc,
    ta.name,
    l.traffic_area_id ta_code,
    'TM' found_as,
    DATE_FORMAT(tml.created_on, '%Y-%m-%d') date_added,
    DATE_FORMAT(tml.deleted_date, '%Y-%m-%d') date_removed,
    rd_disqualified.description disqualified
FROM
    transport_manager tm
        INNER JOIN
    contact_details cd ON (tm.home_cd_id = cd.id)
        INNER JOIN
    person p ON cd.person_id = p.id
        LEFT JOIN
    transport_manager_licence tml ON (tml.transport_manager_id = tm.id)
        LEFT JOIN
    (licence l, organisation o, ref_data rd_lic_type, ref_data rd_lic_status, traffic_area ta, ref_data rd_org_type) ON (o.id = l.organisation_id
        AND l.id = tml.licence_id
        AND rd_lic_type.id = l.licence_type
        AND rd_lic_status.id = l.status
        AND ta.id = l.traffic_area_id
        AND rd_org_type.id = o.type)
        INNER JOIN
    ref_data rd_tm_status ON (rd_tm_status.id = tm.tm_status)
        INNER JOIN
    ref_data rd_disqualified ON (rd_disqualified.id = tm.tm_status)
    INNER JOIN
    elastic_update eu ON (eu.index_name = 'people')
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
    DATE_FORMAT(p.birth_date, '%Y-%m-%d'),
    p.other_name person_other_name,
    p.birth_place person_birth_place,
    p.title person_title,
    DATE_FORMAT(p.deleted_date, '%Y-%m-%d'),
    DATE_FORMAT(p.created_on, '%Y-%m-%d'),
    o.name org_name,
    LOWER(o.name) AS org_name_wildcard,
    rd_org_type.description AS org_type,
    l.lic_no lic_no,
    rd_lic_type.description lic_type_desc,
    rd_lic_status.description lic_status_desc,
    NULL tm_id,
    NULL tm_status_desc,
    ta.name traffic_area,
    l.traffic_area_id,
    rd_found_as.description,
    DATE_FORMAT(op.created_on, '%Y-%m-%d') date_added,
    DATE_FORMAT(op.deleted_date, '%Y-%m-%d') date_removed,
    NULL
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
    ref_data rd_org_type ON (rd_org_type.id = o.type)
        INNER JOIN
    traffic_area ta ON (ta.id = l.traffic_area_id)
        INNER JOIN
    (organisation_type otype, ref_data rd_found_as) ON (otype.org_type_id = o.type
        AND rd_found_as.id = otype.org_person_type_id) 
    INNER JOIN
    elastic_update eu ON (eu.index_name = 'people')
WHERE
    (p.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR l.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))