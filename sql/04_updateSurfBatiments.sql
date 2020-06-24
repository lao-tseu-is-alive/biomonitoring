select clipped.id, clipped.gid,  clipped_geom
from (
         select cs_bati_pol.*,
             (ST_Dump(ST_Intersection(cs_bati_pol.geom, grid_100m.geom))).geom clipped_geom
         from cs_bati_pol
              inner join grid_100m on ST_Intersects(cs_bati_pol.geom, grid_100m.geom)
        where grid_100m.id = 1 AND cs_bati_pol.type = 'BAT'
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2;



UPDATE grid_100m G   SET surf_batie =  null;
WITH myBuildings AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     round(st_area(st_collect(clipped_geom))) as surface,
     count(*)
from (
         select grid_100m.id as idgrid,cs_bati_pol.*,
             (ST_Dump(ST_Intersection(cs_bati_pol.geom, grid_100m.geom))).geom clipped_geom
         from cs_bati_pol
              inner join grid_100m on ST_Intersects(cs_bati_pol.geom, grid_100m.geom)
         where cs_bati_pol.type = 'BAT'
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_100m G
    SET surf_batie =  myBuildings.surface
FROM myBuildings
WHERE G.id = myBuildings.idgrid;

SELECT count(*) FROM  grid_100m WHERE surf_batie > (1000);

VACUUM ANALYSE grid_10m;
UPDATE grid_10m G   SET surf_batie =  null;
WITH myBuildings AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     round(st_area(st_collect(clipped_geom))) as surface,
     count(*)
from (
         select grid_10m.id as idgrid,cs_bati_pol.*,
             (ST_Dump(ST_Intersection(cs_bati_pol.geom, grid_10m.geom))).geom clipped_geom
         from cs_bati_pol
              inner join grid_10m on ST_Intersects(cs_bati_pol.geom, grid_10m.geom)
            where cs_bati_pol.type = 'BAT'
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_10m G
    SET surf_batie =  myBuildings.surface
FROM myBuildings
WHERE G.id = myBuildings.idgrid;
-- on elimine les quantites negligeable pour la grille 10m et 100m
UPDATE  grid_10m G     SET surf_batie = null WHERE surf_batie < 1;
SELECT count(*) FROM  grid_10m WHERE surf_batie  <1;

VACUUM ANALYSE grid_1m;
WITH myBuildings AS (
select clipped.idgrid,
     st_area(st_collect(clipped_geom)) as surface,
     count(*)
from (
         select grid_1m.id as idgrid,cs_bati_pol.*,
             (ST_Dump(ST_Intersection(cs_bati_pol.geom, grid_1m.geom))).geom clipped_geom
         from cs_bati_pol
              inner join grid_1m on ST_Intersects(cs_bati_pol.geom, grid_1m.geom)
         where cs_bati_pol.type = 'BAT'
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_1m G
    SET surf_batie =  myBuildings.surface
FROM myBuildings
WHERE G.id = myBuildings.idgrid;
-- 45937 rows affected in 8 s 909 ms

SELECT count(*)
FROM grid_1m
WHERE surf_batie = 1
AND main_lidar_category != 6