SELECT 
    CONCAT_WS('_',
            IFNULL(addr.id, 'none'),
            IFNULL(app.id, 'none'),
            IFNULL(org.id, 'none'),
            IFNULL(oc.id, 'none'),
            IFNULL(aoc.id, 'none'),
            IFNULL(lic.id, 'none')) AS _id,
    addr.id addr_id,
    app.id AS app_id,
    org.id AS org_id,
    oc.id AS oc_id,
    aoc.id AS aoc_id,
    lic.id AS lic_id,
    lic.lic_no AS lic_no,
    addr.paon_desc AS paon_desc,
    addr.saon_desc AS saon_desc,
    addr.street AS street,
    addr.locality AS locality,
    addr.town AS town,
    addr.postcode AS postcode,
    addr.country_code AS country_code,
    (SELECT 
            description
        FROM
            ref_data
        WHERE
            id = app.status) AS app_status,
    (SELECT 
            description
        FROM
            ref_data
        WHERE
            id = lic.status) AS lic_status,
    (SELECT 
            description
        FROM
            ref_data
        WHERE
            id = org.type) AS org_type,
    (SELECT 
            description
        FROM
            ref_data
        WHERE
            id = lic.licence_type) AS lic_type,
    lic.lic_no AS lic_no,
    org.name org_name,
    LOWER(org.name) org_name_wildcard,
    (SELECT 
            COUNT(oco.operating_centre_id)
        FROM
            operating_centre_opposition oco
        WHERE
            (oco.operating_centre_id = oc.id)) AS oc_opposition_count,
    ta.name AS traffic_area
FROM
    address addr
        INNER JOIN
    operating_centre oc ON addr.id = oc.address_id
        INNER JOIN
    application_operating_centre aoc ON oc.id = aoc.operating_centre_id
        INNER JOIN
    application app ON aoc.application_id = app.id
        INNER JOIN
    licence lic ON app.licence_id = lic.id
        INNER JOIN
    organisation org ON lic.organisation_id = org.id
        INNER JOIN
    traffic_area ta on lic.traffic_area_id = ta.id
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'addresses')
WHERE
    (addr.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR app.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR org.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR oc.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR aoc.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR lic.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))
        