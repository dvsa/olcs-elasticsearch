SELECT 
    CONCAT_WS('_',
            IFNULL(v.id, 'none'),
            IFNULL(l.id, 'none'),
            IFNULL(lv.id, 'none'),
            IFNULL(o.id, 'none'),
            IFNULL(gd.id, 'none')) AS _id,
    r1.description lic_type_desc,
    l.lic_no,
    (SELECT 
            description
        FROM
            ref_data
        WHERE
            l.status = id) AS lic_status_desc,
    v.vrm,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    gd.disc_no disc_no,
    lv.removal_date,
    lv.specified_date,
    r1.id ref_data_id,
    l.id lic_id,
    lv.id lic_veh_id,
    v.id veh_id,
    o.id org_id,
    gd.id gd_id
FROM
    licence l
        INNER JOIN
    ref_data r1 ON (l.goods_or_psv = r1.id)
        INNER JOIN
    licence_vehicle lv ON (l.id = lv.licence_id)
        INNER JOIN
    vehicle v ON (lv.vehicle_id = v.id)
        INNER JOIN
    organisation o ON (l.organisation_id = o.id)
        LEFT JOIN
    goods_disc gd ON (lv.id = gd.licence_vehicle_id)
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'vehicle_removed')
WHERE
    ((v.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR l.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR lv.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR gd.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))
        AND lv.removal_date IS NOT NULL)
        