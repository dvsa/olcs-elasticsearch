SELECT
    CONCAT_WS('_',
            IFNULL(o.id, 'none'),
            IFNULL(l.id, 'none'),
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
    (SELECT
            COUNT(*)
        FROM
            cases
        WHERE
            licence_id = l.id
    ) case_count,
    (
      SELECT GROUP_CONCAT(DISTINCT name ORDER BY tn.id ASC SEPARATOR '|')
      FROM trading_name tn
      WHERE tn.licence_id = l.id AND tn.deleted_date IS NULL
      GROUP BY tn.licence_id
    ) as licence_trading_names,
    ta1.name licence_traffic_area,
    ta2.name lead_tc,
    o.id org_id,
    l.id lic_id,
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
    ref_data r1 ON (o.type = r1.id)
        INNER JOIN
    traffic_area ta1 ON (l.traffic_area_id = ta1.id)
        LEFT JOIN
    traffic_area ta2 ON (o.lead_tc_area_id = ta2.id)
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'licence')
WHERE (
    COALESCE(o.last_modified_on, o.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    OR COALESCE(l.last_modified_on, l.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    OR COALESCE(ta1.last_modified_on, ta1.created_on) > FROM_UNIXTIME(eu.previous_runtime)
)
AND o.deleted_date IS NULL
AND l.deleted_date IS NULL
