SELECT
    o.id AS _id,
    o.id org_id,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    rd.description org_type_desc
FROM
    organisation o
        LEFT JOIN
    ref_data rd ON (o.type = rd.id)
        LEFT JOIN
    elastic_update eu ON (eu.index_name = 'irfo')

WHERE (
    COALESCE(o.last_modified_on, o.created_on, 1) > FROM_UNIXTIME(eu.previous_runtime)
    OR (o.last_modified_on IS NULL AND o.created_on IS NULL)
)
AND o.deleted_date IS NULL
AND o.is_irfo = 1