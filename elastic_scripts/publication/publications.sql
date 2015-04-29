SELECT 
    CONCAT_WS('_',
            IFNULL(pl.id, 'none'),
            IFNULL(p.id, 'none'),
            IFNULL(ta.id, 'none'),
            IFNULL(ps.id, 'none')) AS _id,
    pl.id AS pub_link_id,
    p.id AS pub_id,
    ta.id AS ta_id,
    ps.id AS pub_sec_id,
    p.publication_no AS pub_no,
    p.pub_type AS pub_type,
    p.pub_date AS pub_date,
    p.pub_status AS pub_status,
    rd1.description AS description,
    ta.name AS ta_name,
    ps.description AS pub_sec_desc
FROM
    publication_link pl
        INNER JOIN
    publication p ON pl.publication_id = p.id
        INNER JOIN
    traffic_area ta ON p.traffic_area_id = ta.id
        INNER JOIN
    publication_section ps ON pl.publication_section_id = ps.id
        INNER JOIN
    ref_data rd1 ON p.pub_status = rd1.id
        INNER JOIN
    elastic_updates eu ON (eu.index_name = 'publications')
WHERE
    (pl.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR p.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR ta.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR ps.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))
