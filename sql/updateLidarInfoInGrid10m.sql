create table grid_10m
(
	id serial not null,
	n2_sol_non_permeable int,
	n3_sol_permeable int,
	n4_vegetation_basse int,
    n5_vegetation int,
    n6_batiments int,
    n9_eau int,
    main_lidar_category int,
    canopee_percent int,
    surf_vegetalisees_percent int,
    pleine_terre_percent int,
    sol_libre_percent int,
    surf_permeable_percent int,
    arbres_nombre int,
    surf_arbustive_percent int,
    surf_verte_prive_percent int,
    surf_verte_public_percent int,
    zone_forestiere_percent int,
    zone_verdure_protege_percent int,
    surf_batie_percent int,
    altitude_min double precision,
    altitude_max double precision,
    altitude_mean double precision,
    altitude_median double precision
);
create unique index grid_10m_id_uindex 	on grid_10m (id);
alter table grid_10m add constraint grid_10m_pk primary key (id);
-- add a geometry column
SELECT addgeometrycolumn('grid_10m', 'geom', 21781, 'POLYGON', 2);
DROP INDEX grid_10m_geom_idx;
CREATE INDEX grid_10m_geom_idx ON grid_10m USING gist(geom);
VACUUM ANALYSE grid_10m;

SELECT addgeometrycolumn('my_polygons', 'geom', 21781, 'POLYGON', 2);
CREATE INDEX my_polygons_geom_idx ON my_polygons  USING gist(geom);

VACUUM ANALYSE l3d_1243_14_d;

WITH mygeom AS (SELECT id, geom FROM grid_10m WHERE id < 4)
    SELECT COUNT(*) as num, L.c, mygeom.id
    FROM l3d_1243_14_d L, mygeom
    WHERE st_contains(st_envelope(mygeom.geom), L.geom)
    GROUP BY L.c, mygeom.id;
--32 rows retrieved starting from 1 in 1 s 452 ms (execution: 1 s 427 ms, fetching: 25 ms)

WITH mygeom AS (SELECT id, geom FROM grid_10m WHERE id > 1399 AND  id < 1500 ORDER BY 1),
myAgg AS (SELECT COUNT(*) as num, L.c, mygeom.id
FROM l3d_1243_14_d L,mygeom
WHERE st_contains(st_envelope(mygeom.geom), L.geom)
GROUP BY L.c, mygeom.id)
UPDATE grid_10m G
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
-- [2020-05-28 15:37:43] 148 rows affected in 1 m 8 s 856 ms
-- [2020-05-29 12:46:10] 151 rows affected in 2 m 36 s 487 ms
-- pour 10 row --> 106 ms
-- pour 50 row --> 3207.886 ms
-- pour 100 row --> 24908.216 ms (00:24.908)
-- DONC ON UTILISE  : generateBatchGridData.py pour generer les batch...
-- avec 2 batchs lancé en parallèle avec des UPDATE de 10 grilles à la fois:
--  grep WITH batch01.sql |wc -l    --> 594
--  grep WITH batch02.sql |wc -l    --> 600
--- TOUT LE BAZAR EST CALCULE EN :time psql -f batch02.sql biomonitoring
-- real	0m38.841s user	0m0.106s sys	0m0.054s
-- moins d'une minute pour TOUT !!!

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

WITH mygeom AS (SELECT id, geom FROM grid_10m WHERE id > 0 AND  id < 10 ORDER BY 1),
myAgg AS (SELECT COUNT(*) as num, L.c, mygeom.id
FROM lidar_2015 L,mygeom
WHERE st_contains(st_envelope(mygeom.geom), L.geom)
GROUP BY L.c, mygeom.id)
UPDATE grid_10m G
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
-- batch02 MIN_ID = 9 MAX_ID = 7500
--  grep WITH batch01.sql |wc -l    --> 750
--  batch02 : MIN_ID = 7500 MAX_ID = 14500
--  grep WITH batch02.sql |wc -l    --> 701
-- time psql -f batch01.sql biomonitoring en real	0m27.204s
-- time psql -f batch02.sql biomonitoring en real	0m20.886s
 -- on boucle tout en 47 sec chrono...

WITH mygeom AS (SELECT id, geom FROM grid_10m WHERE id >  8 AND  id < 19 ORDER BY 1),
myAgg AS (SELECT COUNT(*) as num, L.c, mygeom.id
FROM lidar_2015 L,mygeom
WHERE st_contains(st_envelope(mygeom.geom), L.geom)
GROUP BY L.c, mygeom.id)
UPDATE grid_10m
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
WHERE id = mygeom.id
;



-- on check si on a rien loupe
select MIN(id), MAX(id) FROM grid_10m
WHERE main_lidar_category_2015 IS NULL ;


