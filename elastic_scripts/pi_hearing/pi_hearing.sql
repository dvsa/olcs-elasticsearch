SELECT 
CONCAT_WS('_',
            IFNULL(c.id, 'none'),
            IFNULL(l.id, 'none'),
            IFNULL(pi.id, 'none'),
            IFNULL(ph.id, 'none'),
            IFNULL(o.id, 'none'),
            IFNULL(pv.id, 'none')) AS _id,
    c.id AS case_id,
    l.id AS lic_id,
    pi.id pi_id,
    pv.id pv_id,
    ph.id ph_id,
    o.id org_id,
    ph.hearing_date AS hearing_date_time,
    coalesce(ph.pi_venue_other, pv.name) venue,
    l.lic_no lic_no,
    o.name org_name
FROM
    pi_hearing ph
        LEFT JOIN
    pi_venue pv ON (ph.pi_venue_id = pv.id)
        INNER JOIN
    pi ON ph.pi_id = pi.id
        INNER JOIN
    cases c ON pi.case_id = c.id
        INNER JOIN
    licence l ON c.licence_id = l.id
        INNER JOIN
    organisation o ON l.organisation_id = o.id
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'pi_hearing')
WHERE
    (      o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR l.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR c.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR pi.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR pv.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR ph.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))
    
 