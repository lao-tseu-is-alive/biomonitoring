
select clipped.id, clipped.no_eca, clipped_geom
from (
         select cs_bati_pol.id, cs_bati_pol.no_eca,
             (ST_Dump(ST_Intersection(cs_bati_pol.geom, grid_10m.geom))).geom clipped_geom
         from cs_bati_pol
              inner join grid_10m on ST_Intersects(cs_bati_pol.geom, grid_10m.geom)
        where grid_10m.id = 292
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2;

SELECT COUNT(*) FROM goeland_arbres_1243_14_d;
-- on enleve les arbres supprimes idvalidation=2
SELECT COUNT(*),arbres_spp.idvalidation
FROM goeland_arbres_1243_14_d
LEFT OUTER JOIN arbres_spp ON arbres_spp.id_go_obj = goeland_arbres_1243_14_d.idthing
GROUP BY idvalidation;
--SELECT * FROM
DELETE FROM goeland_arbres_1243_14_d
    WHERE idthing IN
(SELECT id_go_obj FROM arbres_spp WHERE idvalidation=2);


-- on compte le nombre d'arbres par grilles
SELECT grid_100m.id as idgrid,COUNT(*) as num
FROM goeland_arbres_1243_14_d
INNER JOIN grid_100m on ST_Intersects(goeland_arbres_1243_14_d.geom, grid_100m.geom)
GROUP BY grid_100m.id
ORDER BY idgrid;

UPDATE grid_100m G SET arbres_nombre = null;
WITH myTrees AS (
    SELECT grid_100m.id as idgrid, COUNT(*) as num
    FROM goeland_arbres_1243_14_d
             INNER JOIN grid_100m on ST_Intersects(goeland_arbres_1243_14_d.geom, grid_100m.geom)
    GROUP BY grid_100m.id
    ORDER BY grid_100m.id)
UPDATE grid_100m G
SET arbres_nombre = myTrees.num
FROM myTrees
WHERE G.id = myTrees.idgrid;
--129 rows affected in 12 ms

SELECT * FROM  grid_100m WHERE arbres_nombre IS NOT NULL;

UPDATE grid_10m G SET arbres_nombre = null;
WITH myTrees AS (
    SELECT grid_10m.id as idgrid, COUNT(*) as num
    FROM goeland_arbres_1243_14_d
             INNER JOIN grid_10m on ST_Intersects(goeland_arbres_1243_14_d.geom, grid_10m.geom)
    GROUP BY grid_10m.id
    ORDER BY grid_10m.id)
UPDATE grid_10m G
SET arbres_nombre = myTrees.num
FROM myTrees
WHERE G.id = myTrees.idgrid;
--1669 rows affected in 104 ms
SELECT COUNT(*) FROM  grid_10m WHERE arbres_nombre IS NOT NULL ;
--reset this field
UPDATE grid_1m G SET arbres_nombre = null;
WITH myTrees AS (
    SELECT grid_1m.id as idgrid, COUNT(*) as num
    FROM goeland_arbres_1243_14_d
             INNER JOIN grid_1m on ST_Intersects(goeland_arbres_1243_14_d.geom, grid_1m.geom)
    GROUP BY grid_1m.id
    ORDER BY grid_1m.id)
UPDATE grid_1m G
SET arbres_nombre = myTrees.num
FROM myTrees
WHERE G.id = myTrees.idgrid;
-- 2475 rows affected in 1 s 139 ms
SELECT COUNT(*) FROM  grid_1m WHERE arbres_nombre IS NOT NULL;
SELECT id,arbres_nombre FROM  grid_1m WHERE arbres_nombre >1;

/*NUM, IsActive, IdValidation
 397	1	2	Supprimé
605	1	5	En attente de soins
1011	1	6	En attente d'abattage
506	1	7	En attente de remplacement
28	1	8	En attente de tomographie
1455	1	9	A surveiller
1015	1	10	En demande d'abattage
318	1	11	En attente de projet
 */


 SELECT * FROM goeland_arbres_1243_14_d
WHERE
SELECT grid_1m.id as idgrid,COUNT(*) as num, min(idthing),max(idthing)
FROM goeland_arbres_1243_14_d
INNER JOIN grid_1m on ST_Intersects(goeland_arbres_1243_14_d.geom, grid_1m.geom)
GROUP BY grid_1m.id
HAVING COUNT(*) > 1
ORDER BY id;
/*
 77510,2,166764,166766
349449,2,131686,131687
393634,2,123892,123893
811151,2,78374,117616
1080949,2,156439,156440
1090573,2,133910,133911
1096950,2,156347,156348
1193578,2,159974,159975
1362739,2,121852,168061
1452581,2,133425,133426
1452582,2,133425,133426

 */