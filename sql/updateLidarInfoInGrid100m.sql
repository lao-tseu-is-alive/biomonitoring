CREATE INDEX grid_100m_geom_idx ON grid_100m USING gist (geom);
VACUUM ANALYSE grid_100m;
create table grid_10m
(
    id                           serial not null,
    n2_sol_non_permeable         int,
    n3_sol_permeable             int,
    n4_vegetation_basse          int,
    n5_vegetation                int,
    n6_batiments                 int,
    n9_eau                       int,
    main_lidar_category          int,
    canopee_percent              int,
    surf_vegetalisees_percent    int,
    pleine_terre_percent         int,
    sol_libre_percent            int,
    surf_permeable_percent       int,
    arbres_nombre                int,
    surf_arbustive_percent       int,
    surf_verte_prive_percent     int,
    surf_verte_public_percent    int,
    zone_forestiere_percent      int,
    zone_verdure_protege_percent int,
    surf_batie_percent           int,
    altitude_min                 double precision,
    altitude_max                 double precision,
    altitude_mean                double precision,
    altitude_median              double precision
);
create unique index grid_10m_id_uindex on grid_10m (id);
alter table grid_10m
    add constraint grid_10m_pk primary key (id);
-- add a geometry column
SELECT addgeometrycolumn('grid_10m', 'geom', 21781, 'POLYGON', 2);



VACUUM ANALYSE l3d_1243_14_d;
VACUUM ANALYSE lidar_2015_2536_1153;
VACUUM ANALYSE lidar_2015_2537_1153;
VACUUM ANALYSE lidar_2015_2538_1153;

explain (analyze on, timing on)
SELECT COUNT(*) as num, c
FROM l3d_1243_14_d
WHERE st_contains(ST_MakeEnvelope(536875, 153000, 536975, 153100, 21781), geom)
GROUP BY c;

WITH mygeom AS (SELECT id, geom FROM grid_100m WHERE id < 4)
SELECT COUNT(*) as num, L.c, mygeom.id
FROM l3d_1243_14_d L,
     mygeom
WHERE st_contains(st_envelope(mygeom.geom), L.geom)
GROUP BY L.c, mygeom.id;
--32 rows retrieved starting from 1 in 1 s 452 ms (execution: 1 s 427 ms, fetching: 25 ms)

WITH mygeom AS (SELECT id, geom FROM grid_100m ORDER BY 1),
     myAgg AS (SELECT COUNT(*) as num, L.c, mygeom.id
               FROM l3d_1243_14_d L,
                    mygeom
               WHERE st_contains(st_envelope(mygeom.geom), L.geom)
               GROUP BY L.c, mygeom.id)
UPDATE grid_100m G
SET n2_sol_non_permeable=(SELECT num FROM myAgg WHERE c = 2 AND myAgg.id = G.id),
    n3_sol_permeable=(SELECT num FROM myAgg WHERE myAgg.c = 3 AND myAgg.id = G.id),
    n4_vegetation_basse=(SELECT num FROM myAgg WHERE myAgg.c = 4 AND myAgg.id = G.id),
    n5_vegetation=(SELECT num FROM myAgg WHERE myAgg.c = 5 AND myAgg.id = G.id),
    n6_batiments=(SELECT num FROM myAgg WHERE myAgg.c = 6 AND myAgg.id = G.id),
    n9_eau=(SELECT num FROM myAgg WHERE myAgg.c = 9 AND myAgg.id = G.id),
    main_lidar_category = (SELECT myAgg.c
                           FROM myAgg
                           WHERE myAgg.id = G.id
                             AND myAgg.c < 10
                           ORDER BY myAgg.num DESC
                           LIMIT 1)
FROM myAgg,
     mygeom
WHERE G.id = mygeom.id;
-- [2020-05-28 15:37:43] 140 rows affected in 2 m 46 s 155 ms

SELECT *
FROM grid_100m
WHERE main_lidar_category > 9;

--- DONNEES LIDAR 2015
WITH mygeom AS (SELECT id, geom FROM grid_100m ORDER BY 1),
     myAgg AS (SELECT COUNT(*) as num, L.c, mygeom.id
               FROM lidar_2015 L,
                    mygeom
               WHERE st_contains(st_envelope(mygeom.geom), L.geom)
               GROUP BY L.c, mygeom.id)
UPDATE grid_100m G
SET n2_sol_2015=(SELECT num FROM myAgg WHERE c = 2 AND myAgg.id = G.id),
    n3_vegetation_basse_2015=(SELECT num FROM myAgg WHERE myAgg.c = 3 AND myAgg.id = G.id),
    n5_vegetation_2015=(SELECT num FROM myAgg WHERE myAgg.c = 5 AND myAgg.id = G.id),
    n6_batiments_2015=(SELECT num FROM myAgg WHERE myAgg.c = 6 AND myAgg.id = G.id),
    n9_eau_2015=(SELECT num FROM myAgg WHERE myAgg.c = 9 AND myAgg.id = G.id),
    main_lidar_category_2015 = (SELECT myAgg.c
                                FROM myAgg
                                WHERE myAgg.id = G.id
                                  AND myAgg.c < 10
                                  AND myAgg.c > 1
                                ORDER BY myAgg.num DESC
                                LIMIT 1)
FROM myAgg,
     mygeom
WHERE G.id = mygeom.id;

CREATE INDEX lidar_2015_geom_idx ON lidar_2015 USING gist (geom);

SELECT main_lidar_category,COUNT(*) as num
FROM grid_100m
GROUP BY main_lidar_category
ORDER BY 1;
SELECT main_lidar_category_2015,COUNT(*) as num
FROM grid_100m
GROUP BY main_lidar_category_2015
ORDER BY 1