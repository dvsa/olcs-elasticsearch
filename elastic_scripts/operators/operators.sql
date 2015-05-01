SELECT
    o.id _id,
	o.id org_id,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    o.is_irfo is_irfo,
    (select count(lic.id) from licence lic where lic.organisation_id = o.id and lic.status = 'lsts_valid') no_of_licences_held,
    'B713SL TODO' postcode,
    'ASSANDUNE HIGHASHES PITHEAVLIS TODO' saon_desc,
    'BACKFORD TODO' town,
    'CH437SZ TODO' irfo_postcode,
    'HAREHILLS LANE TODO' irfo_saon_desc,
    'LEEDS TODO' irfo_town,
    'B' ta_id
FROM
    organisation o
        INNER JOIN
    elastic_updates eu ON (eu.index_name = 'operator')
WHERE
    (o.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))