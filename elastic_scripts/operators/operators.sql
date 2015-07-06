SELECT 
CONCAT_WS('_',
            IFNULL(o.id, 'none'),
            IFNULL(a_org.id, 'none'),
            IFNULL(a_irfo.id, 'none')) AS _id,
    o.id _id,
    o.id org_id,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    o.is_irfo is_irfo,
    (select 
            count(lic.id)
        from
            licence lic
        where
            lic.organisation_id = o.id
                and lic.status in ('lsts_valid','lsts_curtailed','lsts_suspended')) no_of_licences_held,
    a_org.postcode postcode,
    a_org.saon_desc saon_desc,
    a_org.town town,
    a_irfo.postcode irfo_postcode,
    a_irfo.saon_desc irfo_saon_desc,
    a_irfo.town irfo_town
FROM
    organisation o
        INNER JOIN
    elastic_updates eu ON (eu.index_name = 'operator')
        LEFT JOIN 
    (contact_details cd_org, address a_org) ON (cd_org.id = o.contact_details_id AND a_org.id = cd_org.address_id)
        LEFT JOIN
    (contact_details cd_irfo, address a_irfo) ON (cd_irfo.id = o.irfo_contact_details_id and a_irfo.id = cd_irfo.address_id)
WHERE
   (    o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime) OR
        a_org.last_modified_on > FROM_UNIXTIME(eu.previous_runtime) OR
        a_irfo.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))