SELECT 
    CONCAT_WS('_',
            IFNULL(br1.id, 'none'),
            IFNULL(lic.id, 'none'),
            IFNULL(org.id, 'none'),
            IFNULL(lic.status, 'none'),
            IFNULL(br1.status, 'none')) AS _id,
    br1.id AS busreg_id,
    IFNULL(CONCAT(br1.service_no,
                    '(',
                    (SELECT 
                            GROUP_CONCAT(COALESCE(service_no, 'NULL'), '') AS other
                        FROM
                            bus_reg_other_service
                        WHERE
                            bus_reg_id = br1.id),
                    ')'),
            br1.service_no) AS service_no,
    br1.reg_no AS reg_no,
    lic.id AS lic_id,
    lic.lic_no AS lic_no,
    rd_lic_status.description AS lic_status,
    org.name AS org_name,
    org.id AS org_id,
    LOWER(org.name) org_name_wildcard,
    br1.start_point AS start_point,
    br1.finish_point AS finish_point,
    CASE 
        WHEN 
            br1.status = 'breg_s_cancelled'
        THEN 
            DATE_FORMAT(br1.effective_date,'%Y-%m-%d')
        ELSE
            DATE_FORMAT(bus_reg_var0.effective_date,'%Y-%m-%d')
    END AS date_1st_reg,
    CASE
        WHEN
            br1.status = 'breg_s_registered'
                AND br1.end_date <= NOW()
        THEN
            'Expired'
        ELSE rd_bus_status.description
    END AS bus_reg_status,
    br1.route_no,
    br1.variation_no,
    (SELECT 
            name
        FROM
            traffic_area
        WHERE
            lic.traffic_area_id = id) AS traffic_area,
            lic.traffic_area_id as ta_code
FROM
    bus_reg AS br1
        INNER JOIN
    bus_reg AS bus_reg_var0 ON (bus_reg_var0.reg_no = br1.reg_no and bus_reg_var0.variation_no = 0)
        INNER JOIN
    licence lic ON lic.id = br1.licence_id
        INNER JOIN
    organisation AS org ON org.id = lic.organisation_ID
        INNER JOIN
    ref_data AS rd_lic_status ON (rd_lic_status.id = lic.status)
        INNER JOIN
    ref_data AS rd_bus_status ON (rd_bus_status.id = br1.status)
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'busreg')
WHERE
    br1.variation_no = COALESCE(
        (SELECT
            MAX(variation_no)
        FROM
            bus_reg br2
        WHERE
            (
                br2.reg_no = br1.reg_no
                AND br2.status NOT IN ('breg_s_refused' , 'breg_s_withdrawn')
                AND (br2.end_date IS NULL
                OR br2.end_date > NOW()
            )
        )
    ), 0)
    AND (
        COALESCE(br1.last_modified_on, br1.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(lic.last_modified_on, lic.created_on) > FROM_UNIXTIME(eu.previous_runtime)
        OR COALESCE(org.last_modified_on, org.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    )
    AND br1.deleted_date IS NULL
    AND lic.deleted_date IS NULL
    AND org.deleted_date IS NULL
