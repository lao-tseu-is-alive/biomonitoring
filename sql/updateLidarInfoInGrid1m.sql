VACUUM ANALYSE grid_1m;
VACUUM ANALYSE l3d_1243_14_d;
VACUUM ANALYSE lidar_2015;

WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE id < 4)
    SELECT COUNT(*) as num, L.c, mygeom.id
    FROM l3d_1243_14_d L, mygeom
    WHERE st_contains(st_envelope(mygeom.geom), L.geom)
    GROUP BY L.c, mygeom.id;
--32 rows retrieved starting from 1 in 1 s 452 ms (execution: 1 s 427 ms, fetching: 25 ms)

WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE id > 9 AND  id < 110 ORDER BY 1),
myAgg AS (SELECT COUNT(*) as num, L.c, mygeom.id
FROM l3d_1243_14_d L,mygeom
WHERE st_contains(st_envelope(mygeom.geom), L.geom)
GROUP BY L.c, mygeom.id)
UPDATE grid_1m G
    SET
        n2_sol_non_permeable=(SELECT num FROM myAgg WHERE c=2 AND myAgg.id = G.id ),
        n3_sol_permeable=(SELECT num FROM myAgg WHERE myAgg.c=3 AND myAgg.id = G.id),
        n4_vegetation_basse=(SELECT num FROM myAgg WHERE myAgg.c=4 AND myAgg.id = G.id),
        n5_vegetation=(SELECT num FROM myAgg WHERE myAgg.c=5 AND myAgg.id = G.id),
        n6_batiments=(SELECT num FROM myAgg WHERE myAgg.c=6 AND myAgg.id = G.id),
        n9_eau=(SELECT num FROM myAgg WHERE myAgg.c=9 AND myAgg.id = G.id),
        main_lidar_category = (SELECT myAgg.c FROM myAgg
        WHERE myAgg.id = G.id AND  myAgg.c < 10
        ORDER BY myAgg.num DESC LIMIT 1)
FROM myAgg,mygeom
WHERE G.id = mygeom.id;
-- 2020-06-16 15:48:14] 9 rows affected in 85 ms
-- 2020-06-16 15:51:40] 100 rows affected in 20 s 967 ms

-- DONC ON UTILISE  : generateBatchGridData.py pour generer les batch...
-- avec 2 batchs lancé en parallèle avec des UPDATE de 10 grilles à la fois:
-- time psql -f batch01.sql biomonitoring (74050 rows affected)     real	9m56.025s
-- time psql -f batch02.sql biomonitoring (70001 rows affected)     real	9m8.380s
-- soit ~10min avec 2 batchs en exec parallel


SELECT count(*) FROM grid_1m WHERE grid_1m.densite_lidar_2012 IS Null;

WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE id > 0 AND  id < 10 ORDER BY 1),
     myAgg AS (SELECT COUNT(*) as num, min(z) as minZ, max(z) as maxZ,avg(z) as avgZ,  mygeom.id
               FROM l3d_1243_14_d L,
                    mygeom
               WHERE st_contains(st_envelope(mygeom.geom), L.geom)
               GROUP BY mygeom.id)
UPDATE grid_1m G
SET densite_lidar_2012=(SELECT num FROM myAgg WHERE myAgg.id = G.id),
    altitude_min=(SELECT minZ FROM myAgg WHERE myAgg.id = G.id),
    altitude_max=(SELECT maxZ FROM myAgg WHERE myAgg.id = G.id),
    altitude_mean=(SELECT avgZ FROM myAgg WHERE myAgg.id = G.id)
FROM myAgg,
     mygeom
WHERE G.id = mygeom.id;


--------------------------------------------------------------------------------------------
-- ET MAINTENANT on traite les donnees 2015
UPDATE grid_10m G
    SET
        n2_sol_2015=null,
        n3_vegetation_basse_2015=null,
        n5_vegetation_2015=null,
        n6_batiments_2015=null,
        n9_eau_2015=null,
        main_lidar_category_2015 =NULL
WHERE id > 0 AND  id < 10;

WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE id > 0 AND  id < 10 ORDER BY 1),
myAgg AS (SELECT COUNT(*) as num, L.c, mygeom.id
FROM lidar_2015 L,mygeom
WHERE st_contains(st_envelope(mygeom.geom), L.geom)
GROUP BY L.c, mygeom.id)
UPDATE grid_1m G
    SET
        n2_sol_2015=(SELECT num FROM myAgg WHERE c=2 AND myAgg.id = G.id ),
        n3_vegetation_basse_2015=(SELECT num FROM myAgg WHERE myAgg.c=3 AND myAgg.id = G.id),
        n5_vegetation_2015=(SELECT num FROM myAgg WHERE myAgg.c=5 AND myAgg.id = G.id),
        n6_batiments_2015=(SELECT num FROM myAgg WHERE myAgg.c=6 AND myAgg.id = G.id),
        n9_eau_2015=(SELECT num FROM myAgg WHERE myAgg.c=9 AND myAgg.id = G.id),
        main_lidar_category_2015 = (SELECT myAgg.c FROM myAgg
        WHERE myAgg.id = G.id AND  myAgg.c < 10
        ORDER BY myAgg.num DESC LIMIT 1)
FROM myAgg,mygeom
WHERE G.id = mygeom.id;

-- DONC ON UTILISE  : generateBatchGridData.py pour generer deux batch...
-- avec 2 batchs lancé en parallèle avec des UPDATE de 10 grilles à la fois:
-- batch01 MIN_ID = 1 MAX_ID = 755000
--  grep WITH batch01.sql |wc -l    --> 75501
--  batch01 : MIN_ID = 755000 MAX_ID = 1455000
--  grep WITH batch02.sql |wc -l    --> 70001
-- time psql -f batch01.sql biomonitoring en real	6m17.031s
-- time psql -f batch02.sql biomonitoring en real	5m42.508s
 -- on boucle tout en ~6min ...





-- on check si on a rien loupe
select COUNT(*), MIN(id), MAX(id) FROM grid_1m WHERE densite_lidar_2012 > ;
select COUNT(*), MIN(id), MAX(id) FROM grid_1m WHERE main_lidar_category_2015 IS NULL ;
select MIN(densite_lidar_2012), avg(densite_lidar_2012), MAX(densite_lidar_2012),
        MIN(densite_lidar_2015), avg(densite_lidar_2015), MAX(densite_lidar_2015)
FROM grid_1m;


