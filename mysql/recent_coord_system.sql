SELECT
    from_unixtime(b.time), b.*
FROM
    (
        SELECT max(time) as maxtime,coord_name,r_orient,p_orient,y_orient,x_location,y_location,z_location,location_name
        FROM pad.coord_system_db
        GROUP BY coord_name
    ) a
INNER JOIN
    pad.coord_system_db b ON 
        a.coord_name = b.coord_name AND 
        a.maxtime = b.time
ORDER BY
    b.time desc;