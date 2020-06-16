VACUUM ANALYSE grid_100m;
VACUUM ANALYSE grid_10m;
VACUUM ANALYSE grid_1m;

SELECT COUNT(*), no_parc
       FROM cs_verte_prive_no_parc_1243_14_d
GROUP BY no_parc
HAVING COUNT(*) > 1

UPDATE grid_100m G  SET surf_verte_prive = null;
UPDATE grid_100m G  SET surf_verte_public = null;
WITH myGreenPrivate AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     round(st_area(st_collect(clipped_geom))) as surface,
     count(*)
from (
         select grid_100m.id as idgrid,cs_verte_privee_1243_14_d.*,
             (ST_Dump(ST_Intersection(cs_verte_privee_1243_14_d.geom, grid_100m.geom))).geom clipped_geom
         from cs_verte_privee_1243_14_d
              inner join grid_100m on ST_Intersects(cs_verte_privee_1243_14_d.geom, grid_100m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_100m G
    SET surf_verte_prive =  myGreenPrivate.surface
FROM myGreenPrivate
WHERE G.id = myGreenPrivate.idgrid;
--2020-06-09 13:15:44] 125 rows affected in 245 ms
SELECT count(*) FROM  grid_100m WHERE surf_verte_prive IS NOT NULL;
SELECT count(*) FROM  grid_100m WHERE surf_verte_prive  <1;
UPDATE grid_100m SET surf_verte_prive=null WHERE surf_verte_prive  <1;

WITH myGreenPublic AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     round(st_area(st_collect(clipped_geom))) as surface,
     count(*)
from (
         select grid_100m.id as idgrid,cs_verte_publique_1243_14_d.*,
             (ST_Dump(ST_Intersection(cs_verte_publique_1243_14_d.geom, grid_100m.geom))).geom clipped_geom
         from cs_verte_publique_1243_14_d
              inner join grid_100m on ST_Intersects(cs_verte_publique_1243_14_d.geom, grid_100m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_100m G SET surf_verte_public =  myGreenPublic.surface
FROM myGreenPublic
WHERE G.id = myGreenPublic.idgrid;
--2020-06-09 13:23:54] 129 rows affected in 104 ms
SELECT count(*) FROM  grid_100m WHERE surf_verte_public IS NOT NULL;
SELECT count(*) FROM  grid_100m WHERE surf_verte_public < 1;
UPDATE grid_100m G SET surf_verte_public = null WHERE surf_verte_public < 1;
--------------------------- GRILLE 10 m -------------------------------------------------
UPDATE grid_10m G  SET surf_verte_prive = null;
UPDATE grid_10m G  SET surf_verte_public = null;
WITH myGreenPrivate AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     round(st_area(st_collect(clipped_geom))) as surface,
     count(*)
from (
         select grid_10m.id as idgrid,cs_verte_privee_1243_14_d.*,
             (ST_Dump(ST_Intersection(cs_verte_privee_1243_14_d.geom, grid_10m.geom))).geom clipped_geom
         from cs_verte_privee_1243_14_d
              inner join grid_10m on ST_Intersects(cs_verte_privee_1243_14_d.geom, grid_10m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_10m G
    SET surf_verte_prive =  myGreenPrivate.surface
FROM myGreenPrivate
WHERE G.id = myGreenPrivate.idgrid;
--2020-06-09 13:30:50] 8240 rows affected in 2 s 145 ms
SELECT count(*) FROM  grid_10m WHERE surf_verte_prive IS NOT NULL;
SELECT count(*) FROM  grid_10m WHERE surf_verte_prive  <1;
-- on elimine evt les quantites negligeable pour la grille 10m et 100m
UPDATE  grid_10m G SET surf_verte_prive = null WHERE surf_verte_prive < 1;

WITH myGreenPublic AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     round(st_area(st_collect(clipped_geom))) as surface,
     count(*)
from (
         select grid_10m.id as idgrid,cs_verte_publique_1243_14_d.*,
             (ST_Dump(ST_Intersection(cs_verte_publique_1243_14_d.geom, grid_10m.geom))).geom clipped_geom
         from cs_verte_publique_1243_14_d
              inner join grid_10m on ST_Intersects(cs_verte_publique_1243_14_d.geom, grid_10m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_10m G SET surf_verte_public =  myGreenPublic.surface
FROM myGreenPublic
WHERE G.id = myGreenPublic.idgrid;
--2020-06-09 13:32:16] 3761 rows affected in 800 ms
SELECT count(*) FROM  grid_10m WHERE surf_verte_public IS NOT NULL;
SELECT count(*) FROM  grid_10m WHERE surf_verte_public  <1;
-- on elimine evt les quantites negligeable pour la grille 10m et 100m
UPDATE  grid_10m G SET surf_verte_public = null WHERE surf_verte_public < 1;


--------------------------- GRILLE 1 m -------------------------------------------------
UPDATE grid_1m G  SET surf_verte_public = null;
UPDATE grid_1m G SET surf_verte_prive = null ;
WITH myGreenPrivate AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     st_area(st_collect(clipped_geom)) as surface,
     count(*)
from (
         select grid_1m.id as idgrid,cs_verte_privee_1243_14_d.*,
             (ST_Dump(ST_Intersection(cs_verte_privee_1243_14_d.geom, grid_1m.geom))).geom clipped_geom
         from cs_verte_privee_1243_14_d
              inner join grid_1m on ST_Intersects(cs_verte_privee_1243_14_d.geom, grid_1m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_1m G
    SET surf_verte_prive =  myGreenPrivate.surface
FROM myGreenPrivate
WHERE G.id = myGreenPrivate.idgrid;
--2020-06-09 14:00:30] 487144 rows affected in 1 m 8 s 829 ms
SELECT count(*) FROM  grid_1m WHERE surf_verte_prive IS NOT NULL;
SELECT count(*) FROM  grid_1m WHERE surf_verte_prive >1;
UPDATE grid_1m SET surf_verte_prive= 1.0  WHERE surf_verte_prive  >1;


WITH myGreenPublic AS (
select clipped.idgrid,st_area(st_collect(clipped_geom)) ,
     st_area(st_collect(clipped_geom)) as surface,
     count(*)
from (
         select grid_1m.id as idgrid,cs_verte_publique_1243_14_d.*,
             (ST_Dump(ST_Intersection(cs_verte_publique_1243_14_d.geom, grid_1m.geom))).geom clipped_geom
         from cs_verte_publique_1243_14_d
              inner join grid_1m on ST_Intersects(cs_verte_publique_1243_14_d.geom, grid_1m.geom)
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2
GROUP BY clipped.idgrid
ORDER BY idgrid)
UPDATE grid_1m G SET surf_verte_public =  myGreenPublic.surface
FROM myGreenPublic
WHERE G.id = myGreenPublic.idgrid;
--2020-06-09 13:57:47] 191781 rows affected in 29 s 774 ms
SELECT count(*) FROM  grid_1m WHERE surf_verte_public IS NOT NULL;
SELECT count(*), max(surf_verte_public),min(surf_verte_public) FROM  grid_1m WHERE surf_verte_public  <1;


SELECT count(*), min(surf_verte_public),max(surf_verte_public),avg(surf_verte_public)
FROM  grid_100m;
SELECT count(*), min(surf_verte_prive),max(surf_verte_prive),avg(surf_verte_prive)
FROM  grid_100m;

SELECT count(*), min(surf_verte_public),max(surf_verte_public),avg(surf_verte_public)
FROM  grid_10m;
SELECT count(*), min(surf_verte_prive),max(surf_verte_prive),avg(surf_verte_prive)
FROM  grid_10m;

SELECT count(*), min(surf_verte_public),max(surf_verte_public),avg(surf_verte_public)
FROM  grid_1m;
SELECT count(*), min(surf_verte_prive),max(surf_verte_prive),avg(surf_verte_prive)
FROM  grid_1m;




