select clipped.id, clipped.gid,  clipped_geom
from (
         select cs_boisee.*,
             (ST_Dump(ST_Intersection(cs_boisee.geom, grid_100m.geom))).geom clipped_geom
         from cs_boisee
              inner join grid_100m on ST_Intersects(cs_boisee.geom, grid_100m.geom)
        where grid_100m.id = 96
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2;

WITH myForest AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     round(st_area(st_collect(clipped_geom))) as surface,
     count(*)
from (
         select grid_100m.id as idgrid,cs_boisee.*,
             (ST_Dump(ST_Intersection(cs_boisee.geom, grid_100m.geom))).geom clipped_geom
         from cs_boisee
              inner join grid_100m on ST_Intersects(cs_boisee.geom, grid_100m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_100m G
    SET surf_zone_forestiere =  myForest.surface
FROM myForest
WHERE G.id = myForest.idgrid;

SELECT count(*) FROM  grid_100m WHERE surf_zone_forestiere IS NOT NULL;

VACUUM ANALYSE grid_10m;
WITH myForest AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     round(st_area(st_collect(clipped_geom))) as surface,
     count(*)
from (
         select grid_10m.id as idgrid,cs_boisee.*,
             (ST_Dump(ST_Intersection(cs_boisee.geom, grid_10m.geom))).geom clipped_geom
         from cs_boisee
              inner join grid_10m on ST_Intersects(cs_boisee.geom, grid_10m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_10m G
    SET surf_zone_forestiere =  myForest.surface
FROM myForest
WHERE G.id = myForest.idgrid;
-- on elimine les quantites negligeable pour la grille 10m et 100m
UPDATE  grid_10m G
    SET surf_zone_forestiere = null
WHERE surf_zone_forestiere < 1;
SELECT count(*) FROM  grid_10m WHERE surf_zone_forestiere  <1;

VACUUM ANALYSE grid_1m;
WITH myForest AS (
select clipped.idgrid,
     st_area(st_collect(clipped_geom)) as surface,
     count(*)
from (
         select grid_1m.id as idgrid,cs_boisee.*,
             (ST_Dump(ST_Intersection(cs_boisee.geom, grid_1m.geom))).geom clipped_geom
         from cs_boisee
              inner join grid_1m on ST_Intersects(cs_boisee.geom, grid_1m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_1m G
    SET surf_zone_forestiere =  myForest.surface
FROM myForest
WHERE G.id = myForest.idgrid;
-- 45937 rows affected in 8 s 909 ms