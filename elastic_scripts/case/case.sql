SELECT 
    CONCAT_WS('_',
            IFNULL(c.id, 'none'),
            IFNULL(rd_ct.id, 'none'),
            IFNULL(l.id, 'none'),
            IFNULL(o.id, 'none'),
            IFNULL(tm.id, 'none'),
            IFNULL(p_tm.id, 'none'),
            IFNULL(cd_tm.id, 'none'),
            IFNULL(a_lic.id, 'none')) AS _id,
    c.id case_id,
    l.id lic_id,
    l.lic_no,
    tm.id tm_id,
    c.application_id app_id,
    o.id org_id,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    a_lic.postcode correspondence_postcode,
    rd_ct.description case_type_desc,
    c.description case_desc,
    rd_ls.description lic_status_desc,
    rd_as.description app_status_desc,
    p_tm.forename tm_forename,
    p_tm.family_name tm_family_name,
    CONCAT_WS(' ',IFNULL(p_tm.forename, ''),IFNULL(p_tm.family_name, '')) as tm_name,
    CASE 
       WHEN isnull(c.open_date) 
       THEN null 
       ELSE 
           DATE_FORMAT(c.open_date, '%Y-%m-%d') 
       END open_date,
       CASE 
       WHEN isnull(c.closed_date) 
       THEN 'Open'
       ELSE 
           'Closed' 
       END case_status_desc
FROM
    cases c
        LEFT JOIN
    (application a, ref_data rd_as) ON (a.id = c.application_id
        AND a.status = rd_as.id)
        INNER JOIN
    ref_data rd_ct ON (rd_ct.id = c.case_type)
        LEFT JOIN
    (licence l, organisation o, contact_details cd_lic, address a_lic, ref_data rd_ls) ON (c.licence_id = l.id
        AND o.id = l.organisation_id
        AND cd_lic.contact_type = 'ct_corr'
        AND (cd_lic.id = l.correspondence_cd_id)
        AND cd_lic.address_id = a_lic.id
        AND rd_ls.id = l.status)
        LEFT JOIN
    (transport_manager tm, contact_details cd_tm, person p_tm) ON (tm.id = c.transport_manager_id
        AND (cd_tm.id = tm.home_cd_id)
        AND p_tm.id = cd_tm.person_id)
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'case')
WHERE
    (
        COALESCE(c.last_modified_on, c.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(a.last_modified_on, a.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(l.last_modified_on, l.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(o.last_modified_on, o.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(cd_lic.last_modified_on, cd_lic.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(a_lic.last_modified_on, a_lic.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(tm.last_modified_on, tm.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(p_tm.last_modified_on, p_tm.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    )
    AND c.deleted_date IS NULL
