SELECT
    CONCAT_WS('_',
            IFNULL(ta.id, 'none'),
            IFNULL(rta.recipient_id, 'none')) AS _id,
    ta.id ta_id,
    ta.name traffic_area,
    rta.recipient_id r_id,
    r.contact_name,
    r.email_address
FROM
    recipient r
        INNER JOIN
    recipient_traffic_area rta ON (rta.recipient_id = r.id)
        INNER JOIN
    traffic_area ta ON (ta.id = rta.traffic_area_id)
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'recipient')
WHERE (
    COALESCE(r.last_modified_on, r.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    OR COALESCE(ta.last_modified_on, ta.created_on) > FROM_UNIXTIME(eu.previous_runtime)
)
AND r.deleted_date IS NULL
