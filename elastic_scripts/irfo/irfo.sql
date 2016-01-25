SELECT
    CONCAT_WS('_',IFNULL(o.id, 'none'),
                  IFNULL(ipa.id, 'none')) AS _id,
    o.id org_id,
    ipa.id ipa_id,
    ipa.status irfo_status,
    ipa.service_route_from,
    ipa.service_route_to,
    rd_ipa_status.description irfo_status_desc,
    (SELECT GROUP_CONCAT(l.lic_no SEPARATOR ',') FROM licence l WHERE l.organisation_id = o.id) related_lic_num,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    rd.description org_type_desc
FROM
    irfo_psv_auth ipa
        LEFT JOIN
    organisation o ON (ipa.organisation_id = o.id)
        LEFT JOIN
    ref_data rd ON (o.type = rd.id)
        LEFT JOIN
    ref_data rd_ipa_status ON (ipa.status = rd_ipa_status.id)
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'irfo')

    AND (
        COALESCE(o.last_modified_on, o.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(ipa.last_modified_on, ipa.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    )