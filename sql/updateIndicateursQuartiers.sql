
	alter table quartiers_1243_14_d add column num_main_lidar_category integer;
    alter table quartiers_1243_14_d add column num_main_lidar_category_2 integer;
    alter table quartiers_1243_14_d add column num_main_lidar_category_3 integer;
    alter table quartiers_1243_14_d add column num_main_lidar_category_4 integer;
    alter table quartiers_1243_14_d add column num_main_lidar_category_5 integer;
    alter table quartiers_1243_14_d add column num_main_lidar_category_6 integer;
    alter table quartiers_1243_14_d add column num_main_lidar_category_9 integer;
	alter table quartiers_1243_14_d add column main_lidar_category_2015 integer;
	alter table quartiers_1243_14_d add column surf_canopee integer;
	alter table quartiers_1243_14_d add column surf_vegetalisees integer;
	alter table quartiers_1243_14_d add column pleine_terre integer;
	alter table quartiers_1243_14_d add column sol_libre integer;
	alter table quartiers_1243_14_d add column surf_permeable integer;
	alter table quartiers_1243_14_d add column arbres_nombre integer;
	alter table quartiers_1243_14_d add column surf_arbustive integer;
	alter table quartiers_1243_14_d add column surf_verte_prive integer;
	alter table quartiers_1243_14_d add column surf_verte_public integer;
	alter table quartiers_1243_14_d add column surf_zone_forestiere integer;
	alter table quartiers_1243_14_d add column surf_zone_verdure_protege integer;
	alter table quartiers_1243_14_d add column surf_batie integer;
	alter table quartiers_1243_14_d add column altitude_min double precision;
	alter table quartiers_1243_14_d add column altitude_max double precision;
	alter table quartiers_1243_14_d add column altitude_mean double precision;
	alter table quartiers_1243_14_d add column nombre_habitants integer;

--pour chaque polygones
WITH myPoly AS (SELECT id,geom FROM quartiers_1243_14_d WHERE numquartie=1),
     myGrids AS (
         SELECT grid_1m.*
         FROM grid_1m, myPoly
         WHERE st_intersects(myPoly.geom, grid_1m.geom)),
     myAggr AS (
    SELECT count(*) as num, myGrids.main_lidar_category
    FROM myGrids
    GROUP BY myGrids.main_lidar_category
    ORDER BY 1 DESC
    )
UPDATE quartiers_1243_14_d Q
SET
    num_main_lidar_category_2 = (SELECT myAggr.num FROM myAggr WHERE myAggr.main_lidar_category=2),
    num_main_lidar_category_3 = (SELECT myAggr.num FROM myAggr WHERE myAggr.main_lidar_category=3),
    num_main_lidar_category_4 = (SELECT myAggr.num FROM myAggr WHERE myAggr.main_lidar_category=4),
    num_main_lidar_category_5 = (SELECT myAggr.num FROM myAggr WHERE myAggr.main_lidar_category=5),
    num_main_lidar_category_6 = (SELECT myAggr.num FROM myAggr WHERE myAggr.main_lidar_category=6),
    num_main_lidar_category_9 = (SELECT myAggr.num FROM myAggr WHERE myAggr.main_lidar_category=9)
FROM myAggr,myPoly
WHERE Q.id = myPoly.id;

WITH myPoly AS (SELECT id,geom FROM quartiers_1243_14_d WHERE id=14),
     myGrids AS (
         SELECT grid_1m.*
         FROM grid_1m, myPoly
         WHERE st_intersects(myPoly.geom, grid_1m.geom)),
     myAggr AS (
    SELECT
           min(myGrids.id) as minid, max(myGrids.id) as maxid, count(*) as num,
           sum(myGrids.surf_permeable) as surf_permeable,
           sum(myGrids.arbres_nombre) as arbres_nombre,
           sum(myGrids.surf_batie) as surf_batie,
           sum(myGrids.surf_verte_prive) as surf_verte_prive,
           sum(myGrids.surf_verte_public) as surf_verte_public,
           min(myGrids.altitude_min) as altitude_min,
           max(myGrids.altitude_max) as altitude_max,
           avg(myGrids.altitude_mean) as altitude_mean,
           sum(myGrids.surf_zone_forestiere) as surf_zone_forestiere
    FROM myGrids
    ORDER BY 1 DESC
    )
UPDATE quartiers_1243_14_d Q
SET surf_permeable = (SELECT surf_permeable FROM myAggr),
    arbres_nombre = (SELECT arbres_nombre FROM myAggr),
    surf_batie = (SELECT surf_batie FROM myAggr),
    surf_verte_prive = (SELECT surf_verte_prive FROM  myAggr),
    surf_verte_public = (SELECT surf_verte_public FROM myAggr),
    altitude_min = (SELECT altitude_min FROM myAggr),
    altitude_mean = (SELECT altitude_mean FROM myAggr),
    altitude_max = (SELECT altitude_max FROM myAggr),
    surf_zone_forestiere = (SELECT surf_zone_forestiere FROM myAggr)
FROM myAggr,myPoly
WHERE Q.id = myPoly.id;

/*
WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE main_lidar_category_2015 IS NULL),
     -- avec les id de ces grilles ou on a pas de main_lidar_category
     -- on compte les valeurs distinctes de main_lidar_category autour
     myagg AS (SELECT mygeom.id, a.main_lidar_category_2015, count(*) as num
               FROM grid_1m as a,
                    mygeom
               WHERE st_intersects((st_buffer(mygeom.geom, 0.00001)), a.geom)
                 AND a.main_lidar_category_2015 IS NOT NULL
               GROUP BY mygeom.id, a.main_lidar_category_2015, mygeom.id
               ORDER BY mygeom.id, num)
SELECT mytopcategory.*
FROM ( -- et on retient la categorie qui est la plus representee autour du la grille manquante
         SELECT distinct myagg.id,
                         myagg.num,
                         myagg.main_lidar_category_2015,
                         rank() OVER (
                             partition by myagg.id
                             ORDER BY myagg.num DESC , myagg.main_lidar_category_2015 ASC
                             )
         FROM myagg
         ORDER BY myagg.id) mytopcategory
WHERE mytopcategory.rank < 2
ORDER BY mytopcategory.id;

