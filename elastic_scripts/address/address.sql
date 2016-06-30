SELECT
    CONCAT_WS('_',
        IFNULL(addr.id, 'none'),
        IFNULL(org.id, 'none'),
        IFNULL(oc.id, 'none'),
        IFNULL(lic.id, 'none')) AS _id,
    addr.id addr_id,
    org.id AS org_id,
    oc.id AS oc_id,
    loc.id AS loc_id,
    lic.id AS lic_id,
    null AS app_id,
    lic.lic_no AS lic_no,
    rd.description AS lic_status_desc,
    'OC' address_type,
    addr.paon_desc AS paon_desc,
    addr.saon_desc AS saon_desc,
    addr.street AS street,
    addr.locality AS locality,
    addr.town AS town,
    addr.postcode AS postcode,
    addr.country_code AS country_code,
    org.name org_name,
    LOWER(org.name) org_name_wildcard,
    com_case.id complaint_case_id,
    opp_case.id opposition_case_id,
    IF(com_case.id IS NULL, 'No', 'Yes') complaint,
    IF(opp_case.id IS NULL, 'No', 'Yes') opposition
FROM
    address addr
        INNER JOIN
    operating_centre oc ON addr.id = oc.address_id
        INNER JOIN
    licence_operating_centre loc ON oc.id = loc.operating_centre_id
        INNER JOIN
    licence lic ON loc.licence_id = lic.id
        INNER JOIN
    ref_data rd on rd.id = lic.status
        INNER JOIN
    organisation org ON lic.organisation_id = org.id
        LEFT JOIN
    (oc_complaint occ, complaint com, cases com_case) ON (occ.operating_centre_id = oc.id
        AND com.id = occ.complaint_id
        AND com_case.id = com.case_id
        AND com.closed_date IS NULL
        AND com_case.licence_id = lic.id)
        LEFT JOIN
    application com_app ON (com_app.id = com_case.application_id
        AND com_app.status NOT IN ('apsts_granted' , 'apsts_withdrawn'))
        LEFT JOIN
    (operating_centre_opposition oco, opposition opp, cases opp_case) ON (oco.operating_centre_id = oc.id
        AND oco.opposition_id = opp.id
        AND opp.case_id = opp_case.id
        AND opp_case.closed_date IS NULL
        AND opp.deleted_date IS NULL
        AND opp_case.licence_id = lic.id)
        INNER JOIN
    elastic_update eu ON eu.index_name = 'address'
WHERE
    (
        COALESCE(addr.last_modified_on, addr.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(com_app.last_modified_on, com_app.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(org.last_modified_on, org.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(oc.last_modified_on, oc.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(loc.last_modified_on, loc.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(lic.last_modified_on, lic.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    )
    AND com_app.deleted_date IS NULL
    AND org.deleted_date IS NULL
    AND loc.deleted_date IS NULL
    AND lic.deleted_date IS NULL
UNION ALL
SELECT
    CONCAT_WS('_',
        IFNULL(addr.id, 'none'),
        IFNULL(org.id, 'none'),
        IFNULL(oc.id, 'none'),
        IFNULL(lic.id, 'none')) AS _id,
    addr.id addr_id,
    org.id AS org_id,
    oc.id AS oc_id,
    aoc.id AS loc_id,
    lic.id AS lic_id,
    app.id AS app_id,
    lic.lic_no AS lic_no,
    rd.description AS lic_status_desc,
    'OC' address_type,
    addr.paon_desc AS paon_desc,
    addr.saon_desc AS saon_desc,
    addr.street AS street,
    addr.locality AS locality,
    addr.town AS town,
    addr.postcode AS postcode,
    addr.country_code AS country_code,
    org.name org_name,
    LOWER(org.name) org_name_wildcard,
    com_case.id complaint_case_id,
    opp_case.id opposition_case_id,
    IF(com_case.id IS NULL, 'No', 'Yes') complaint,
    IF(opp_case.id IS NULL, 'No', 'Yes') opposition
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
    ref_data rd on rd.id = lic.status
        INNER JOIN
    organisation org ON lic.organisation_id = org.id
        LEFT JOIN
    (oc_complaint occ, complaint com, cases com_case) ON (occ.operating_centre_id = oc.id
        AND com.id = occ.complaint_id
        AND com_case.id = com.case_id
        AND com.closed_date IS NULL
        AND com_case.licence_id = lic.id)
        LEFT JOIN
    application com_app ON (com_app.id = com_case.application_id
        AND com_app.status NOT IN ('apsts_granted' , 'apsts_withdrawn'))
        LEFT JOIN
    (operating_centre_opposition oco, opposition opp, cases opp_case) ON (oco.operating_centre_id = oc.id
        AND oco.opposition_id = opp.id
        AND opp.case_id = opp_case.id
        AND opp_case.closed_date IS NULL
        AND opp.deleted_date IS NULL
        AND opp_case.licence_id = lic.id)
        INNER JOIN
    elastic_update eu ON eu.index_name = 'address'
WHERE
    app.status <> 'apsts_not_submitted'
    AND
    (
        COALESCE(addr.last_modified_on, addr.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(com_app.last_modified_on, com_app.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(org.last_modified_on, org.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(oc.last_modified_on, oc.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(aoc.last_modified_on, aoc.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(lic.last_modified_on, lic.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(app.last_modified_on, app.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    )
    AND com_app.deleted_date IS NULL
    AND org.deleted_date IS NULL
    AND aoc.deleted_date IS NULL
    AND lic.deleted_date IS NULL
    AND app.deleted_date IS NULL
UNION ALL
    SELECT
    CONCAT_WS('_',
            IFNULL(addr.id, 'none'),
            IFNULL(org.id, 'none'),
            'null',
            IFNULL(lic.id, 'none')) AS _id,
    addr.id addr_id,
    org.id AS org_id,
    null oc_id,
    null loc_id,
    lic.id AS lic_id,
    null AS app_id,
    lic.lic_no AS lic_no,
    rd.description AS lic_status,
    'Correspondence' address_type,
    addr.paon_desc AS paon_desc,
    addr.saon_desc AS saon_desc,
    addr.street AS street,
    addr.locality AS locality,
    addr.town AS town,
    addr.postcode AS postcode,
    addr.country_code AS country_code,
    org.name org_name,
    LOWER(org.name) org_name_wildcard,
    null complaint_case_id,
    null opposition_case_id,
    'No' complaint,
    'No' opposition
FROM
    address addr
      INNER JOIN contact_details cd
      ON addr.id = cd.address_id
        INNER JOIN
    licence lic ON lic.correspondence_cd_id = cd.id
        INNER JOIN
    ref_data rd on rd.id = lic.status
        INNER JOIN
    organisation org ON lic.organisation_id = org.id
        INNER JOIN
    elastic_update eu ON eu.index_name = 'address'
WHERE
    (
        COALESCE(addr.last_modified_on, addr.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(org.last_modified_on, org.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(lic.last_modified_on, lic.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    )
    AND org.deleted_date IS NULL
    AND lic.deleted_date IS NULL
