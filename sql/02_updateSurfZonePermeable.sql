select clipped.id,   clipped_geom
from (
         select S.*,
             (ST_Dump(ST_Intersection(S.geom, grid_100m.geom))).geom clipped_geom
         from surface_permeable_sans_dp_cff_ni_bat_hors_sols_1243_14_d S
              inner join grid_100m on ST_Intersects(S.geom, grid_100m.geom)
        where grid_100m.id = 96
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2;
------------------------------------------------------------
UPDATE grid_100m G   SET surf_permeable =  null;

WITH mySurf AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     round(st_area(st_collect(clipped_geom))) as surface,
     count(*)
from (
         select grid_100m.id as idgrid,S.*,
             (ST_Dump(ST_Intersection(S.geom, grid_100m.geom))).geom clipped_geom
         from surface_permeable_sans_dp_cff_ni_bat_hors_sols_1243_14_d S
              inner join grid_100m on ST_Intersects(S.geom, grid_100m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_100m G
    SET surf_permeable =  mySurf.surface
FROM mySurf
WHERE G.id = mySurf.idgrid;

SELECT count(*) FROM  grid_100m WHERE surf_permeable IS NOT NULL;
SELECT count(*),min(surf_permeable),max(surf_permeable) FROM  grid_100m WHERE surf_permeable IS NOT NULL;
-------------------------------------------------------------------------
VACUUM ANALYSE grid_10m;
UPDATE grid_10m G   SET surf_zone_forestiere =  null;
WITH mySurf AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     round(st_area(st_collect(clipped_geom))) as surface,
     count(*)
from (
         select grid_10m.id as idgrid,S.*,
             (ST_Dump(ST_Intersection(S.geom, grid_10m.geom))).geom clipped_geom
         from surface_permeable_sans_dp_cff_ni_bat_hors_sols_1243_14_d S
              inner join grid_10m on ST_Intersects(S.geom, grid_10m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_10m G
    SET surf_permeable =  mySurf.surface
FROM mySurf
WHERE G.id = mySurf.idgrid;
SELECT count(*) FROM  grid_10m WHERE surf_permeable IS NOT NULL;
-- on elimine les quantites negligeable pour la grille 10m et 100m
UPDATE  grid_10m G SET surf_permeable = null WHERE surf_permeable < 1;
SELECT count(*) FROM  grid_10m WHERE surf_permeable  <1;
-------------------------------------------------------------------------
VACUUM ANALYSE grid_1m;
WITH mySurf AS (
select clipped.idgrid,
     st_area(st_collect(clipped_geom)) as surface,
     count(*)
from (
         select grid_1m.id as idgrid,S.*,
             (ST_Dump(ST_Intersection(S.geom, grid_1m.geom))).geom clipped_geom
         from surface_permeable_sans_dp_cff_ni_bat_hors_sols_1243_14_d S
              inner join grid_1m on ST_Intersects(S.geom, grid_1m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_1m G
    SET surf_permeable =  mySurf.surface
FROM mySurf
WHERE G.id = mySurf.idgrid;

SELECT count(*) FROM  grid_1m WHERE surf_permeable IS NOT NULL;
SELECT count(*) FROM  grid_1m WHERE surf_permeable  <0.0001;
-- 45937 rows affected in 8 s 909 ms