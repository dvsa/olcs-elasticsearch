SELECT 
    CONCAT_WS('_',IFNULL(o.id, 'none'),
                  IFNULL(ipa.id, 'none')) AS _id,
    ipa.status irfo_status,
    rd_ipa_status.description irfo_status_desc,
    o.id org_id,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    rd.description org_type
FROM
    irfo_psv_auth ipa
        INNER JOIN 
    organisation o ON (ipa.organisation_id = o.id)
        INNER JOIN
    ref_data rd ON (o.type = rd.id)
        INNER JOIN
    ref_data rd_ipa_status ON (ipa.status = rd_ipa_status.id)
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'irfo')
    
WHERE
    o.is_irfo = 1 
    AND
    (o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
      OR ipa.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))