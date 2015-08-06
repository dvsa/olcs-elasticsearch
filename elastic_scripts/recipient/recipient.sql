select
    CONCAT_WS('_',
            IFNULL(ta.id, 'none'),
            IFNULL(rta.recipient_id, 'none')) AS _id,
    ta.id ta_id,
    ta.name traffic_area,
    rta.recipient_id r_id, 
    r.contact_name, 
    r.email_address
from
    recipient r
        inner join
    recipient_traffic_area rta ON (rta.recipient_id = r.id)
        inner join
    traffic_area ta ON (ta.id = rta.traffic_area_id)
        INNER JOIN
    elastic_updates eu ON (eu.index_name = 'recipient')
WHERE (r.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR ta.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))