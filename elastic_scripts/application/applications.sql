SELECT 
    CONCAT_WS('_',
            IFNULL(o.id, 'none'),
            IFNULL(l.id, 'none'),
            IFNULL(a.id, 'none'),
            IFNULL(ad.id, 'none')) AS _id,
    a.id app_id,
    l.id lic_id,
    l.lic_no,
    o.id org_id,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    ad.postcode correspondence_postcode,
    a.tot_auth_vehicles,
    a.tot_auth_trailers,
    case when isnull(a.received_date) then null else date_format(a.received_date, '%d/%m/%Y') end, 
    rd_lt.description lic_type_desc,
    rd_ls.description lic_status_desc,
    rd_as.description app_status_desc
FROM
    application a
        INNER JOIN
    licence l ON (a.licence_id = l.id)
        INNER JOIN
    organisation o ON (l.organisation_id = o.id)
        LEFT JOIN
    (contact_details cd, address ad) ON (cd.id = l.correspondence_cd_id
        AND cd.Contact_Type = 'ct_corr'
        AND cd.address_id = ad.id)
        INNER JOIN
    ref_data rd_lt ON (rd_lt.id = l.licence_type)
        INNER JOIN
    ref_data rd_ls ON (rd_ls.id = l.status)
        INNER JOIN
    ref_data rd_as ON (rd_as.id = a.status)
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'application')
WHERE
    (ad.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR a.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR l.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))