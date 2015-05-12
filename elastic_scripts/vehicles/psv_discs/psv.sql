SELECT 
    CONCAT_WS('_',
            IFNULL(l.id, 'none'),
            IFNULL(o.id, 'none'),
            IFNULL(psv.id, 'none')) AS _id,
    r1.description lic_type_desc,
    l.lic_no,
    (SELECT 
            description
        FROM
            ref_data
        WHERE
            l.status = id) AS lic_status_desc,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    psv.disc_no disc_no,
    l.id lic_id,
    o.id org_id,
    psv.id psv_id
FROM
    licence l
        LEFT JOIN
    ref_data r1 ON (l.goods_or_psv = r1.id)
        INNER JOIN
    organisation o ON (l.organisation_id = o.id)
        LEFT JOIN
    psv_disc psv ON (l.id = psv.licence_id)
        INNER JOIN
    elastic_updates eu ON (eu.index_name = 'psv_disc')
WHERE
    (o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR psv.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR l.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))
        