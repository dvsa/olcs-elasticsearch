SELECT
    CONCAT_WS('_',
            IFNULL(u.id, 'none'),
            IFNULL(r.id, 'none'),
            IFNULL(o.id, 'none'),
            IFNULL(cd.id, 'none'),
            IFNULL(l.id, 'none'),
            IFNULL(la.id, 'none')) AS _id,
    u.id user_id,
    u.login_id,
    r.id role_id,
    o.id org_id,
    la.id la_id,
    GROUP_CONCAT(l.lic_no SEPARATOR ', ') AS lic_nos,
    cd.id con_det_id,
    u.pid identity_pid,
    u.team_id,
    cd.email_address,
    p.forename,
    p.family_name,
    t.name team_name,
    o.name org_name,
    LOWER(o.name) org_name_wildcard,
    r.description user_type,
    r.role,
    t.name description,
    cd_partner.description partner_name,
    la.description la_name,
    coalesce(la.description,cd_partner.description, o.name, t.name) entity,

    CASE
       WHEN isnull(u.deleted_date)
       THEN null
       ELSE
           DATE_FORMAT(u.deleted_date, '%Y-%m-%d')
       END deleted_date
FROM
    user u
        LEFT JOIN
    team t  ON (u.team_id = t.id)
        LEFT JOIN
    user_role ur ON (ur.user_id = u.id)
        LEFT JOIN
    role r ON (r.id = ur.role_id)
        LEFT JOIN
    organisation_user ou ON (ou.user_id = u.id)
        LEFT JOIN
    licence l ON (l.organisation_id = ou.organisation_id)
        LEFT JOIN
    organisation o ON (o.id = ou.organisation_id)
        INNER JOIN
    (contact_details cd, person p) ON (cd.id = u.contact_details_id AND p.id = cd.person_id)
        LEFT JOIN
    (contact_details cd_partner, person partner) ON (cd_partner.id = u.partner_contact_details_id AND partner.id = cd_partner.person_id)
        LEFT JOIN
    local_authority la ON (la.id = u.local_authority_id)
        INNER JOIN
    elastic_update eu ON (eu.index_name = 'user')
WHERE
    (
    COALESCE(u.last_modified_on, u.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    OR COALESCE(r.last_modified_on, r.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    OR COALESCE(o.last_modified_on, o.created_on) > FROM_UNIXTIME(eu.previous_runtime)
    OR COALESCE(cd.last_modified_on, cd.created_on) > FROM_UNIXTIME(eu.previous_runtime)
  )
  AND u.deleted_date IS NULL
  AND cd.deleted_date IS NULL
  GROUP BY u.id
