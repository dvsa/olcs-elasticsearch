SELECT 
    CONCAT_WS('_',
            IFNULL(pl.id, 'none'),
            IFNULL(p.id, 'none'),
            IFNULL(ta.id, 'none'),
            IFNULL(ps.id, 'none'),
            IFNULL(l.id, 'none'),
            IFNULL(o.id, 'none')) AS _id,
    pl.id AS pub_link_id,
    l.id lic_id,
    o.id org_id,
    l.lic_no lic_no,
    l.licence_type lic_type,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    rd_lt.description lic_type_desc,
    p.id AS pub_id,
    ta.id AS ta_id,
    ps.id AS pub_sec_id,
    p.publication_no AS pub_no,
    p.pub_type AS pub_type,
    CASE 
       WHEN isnull(p.pub_date) 
       THEN null 
       ELSE 
           DATE_FORMAT(p.pub_date, '%Y-%m-%d') 
       END pub_date,
    p.pub_status AS pub_status,
    rd1.description AS description,
    ta.name AS traffic_area,
    ps.description AS pub_sec_desc,
    pl.text1 text1,
    pl.text2 text2,
    pl.text3 text3,
    CONCAT_WS(' ',
            IFNULL(pl.text1, ''),
            IFNULL(pl.text2, ''),
            IFNULL(pl.text3, '')) AS text_all
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
    elastic_update eu ON (eu.index_name = 'publications')
        LEFT JOIN (licence l INNER JOIN organisation o) ON l.id = pl.licence_id AND l.organisation_id = o.id
    INNER join
    ref_data rd_lt ON (rd_lt.id = l.licence_type)
WHERE
    (pl.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR p.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR ta.last_modified_on > FROM_UNIXTIME(eu.previous_runtime)
        OR ps.last_modified_on > FROM_UNIXTIME(eu.previous_runtime))