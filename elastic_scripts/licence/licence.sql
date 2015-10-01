SELECT 
    CONCAT_WS('_',
            IFNULL(o.id, 'none'),
            IFNULL(l.id, 'none'),
            IFNULL(a.id, 'none'),
            IFNULL(r1.id, 'none'),
            IFNULL(ta1.id, 'none')) AS _id,
    l.lic_no,
    l.fabs_reference,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    o.company_or_llp_no,
    (SELECT 
            COUNT(lic.id)
        FROM
            licence lic
        WHERE
            lic.organisation_id = o.id
                AND lic.status = 'lsts_valid') no_of_licences_held,
    IF((SELECT 
                COUNT(lic.id)
            FROM
                licence lic
            WHERE
                lic.organisation_id = o.id
                    AND lic.status = 'lsts_valid') > 1,
        'yes',
        'no') is_mlh,
    r1.description org_type_desc,
    r1.description org_type_desc_whole,
    rd_lt.description lic_type_desc,
    rd_lt.description lic_type_desc_whole,
    rd_ls.description lic_status_desc,
    rd_ls.description lic_status_desc_whole,
    a.postcode correspondence_postcode,
    a.saon_desc,
    a.town,
    (SELECT 
            COUNT(*)
        FROM
            cases
        WHERE
            licence_id = l.id) case_count,
    tn.name trading_name,
    ta1.name licence_traffic_area,
    ta2.name lead_tc,
    o.id org_id,
    l.id lic_id,
    a.id addr_id,
    r1.id ref_data_id,
    ta1.id ta_id
FROM
    licence l
        INNER JOIN
    organisation o ON (l.organisation_id = o.id)
        INNER JOIN
    ref_data rd_lt ON (rd_lt.id = l.licence_type)
        INNER JOIN
    ref_data rd_ls ON (rd_ls.id = l.status)
        LEFT JOIN
    (contact_details cd, address a) ON (cd.id = l.correspondence_cd_id
        AND cd.contact_type = 'ct_corr'
        AND cd.address_id = a.id)
        LEFT JOIN
    ref_data r1 ON (o.type = r1.id)
        LEFT JOIN
    trading_name tn ON (l.id = tn.licence_id)
        INNER JOIN
    traffic_area ta1 ON (l.traffic_area_id = ta1.id)
        LEFT JOIN
    traffic_area ta2 ON (o.lead_tc_area_id = ta2.id)
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'licence')
WHERE
    (o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR a.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR l.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR ta1.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))
        