SELECT COUNT(*), main_lidar_category
FROM grid_1m
GROUP BY main_lidar_category ;

-- on corrige main_lidar_category qui sont null
-- si categorie des points lidars est 13 vehicules objets temp
-- on recupere les id de grilles 1m concernes dans table temp_nullgrid
-- et on update toutes ces grilles  main_lidar_category avec 2 (sol impermeable)

WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE main_lidar_category IS NULL)
    SELECT COUNT(*) as num, L.c, mygeom.id
    INTO temp_nullgrid
    FROM l3d_1243_14_d L, mygeom
    WHERE st_contains(st_envelope(mygeom.geom), L.geom)
    AND L.c = 13
    GROUP BY L.c, mygeom.id
;
SELECT count(*),main_lidar_category   FROM grid_1m
WHERE id IN (SELECT id from temp_nullgrid)
GROUP BY main_lidar_category;

UPDATE grid_1m
SET main_lidar_category = 2
WHERE id IN (SELECT id from temp_nullgrid);

SELECT count(*),id FROM temp_nullgrid
GROUP BY id,c
HAVING count(*) > 1;


-- on corrige main_lidar_category qui sont null
-- si categorie des points lidars est 11 mobilier urbain
-- on recupere les id de grilles 1m concernes dans table temp_nullgrid
-- et on update toutes ces grilles  main_lidar_category avec 2 (sol impermeable)
DROP TABLE temp_nullgrid;
WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE main_lidar_category IS NULL)
    SELECT COUNT(*) as num, L.c , mygeom.id
    INTO temp_nullgrid
    FROM l3d_1243_14_d L, mygeom
    WHERE st_contains(st_envelope(mygeom.geom), L.geom)
    AND L.c = 11
    GROUP BY L.c, mygeom.id
;
SELECT count(*),main_lidar_category   FROM grid_1m
WHERE id IN (SELECT id from temp_nullgrid)
GROUP BY main_lidar_category;

UPDATE grid_1m
SET main_lidar_category = 2
WHERE id IN (SELECT id from temp_nullgrid);

-- on corrige main_lidar_category qui sont null
-- si categorie des points lidars est 10 ponts passerelles
-- on recupere les id de grilles 1m concernes dans table temp_nullgrid
-- et on update toutes ces grilles  main_lidar_category avec 2 (sol impermeable)
DROP TABLE temp_nullgrid;
WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE main_lidar_category IS NULL)
    SELECT COUNT(*) as num, L.c , mygeom.id
    INTO temp_nullgrid
    FROM l3d_1243_14_d L, mygeom
    WHERE st_contains(st_envelope(mygeom.geom), L.geom)
    AND L.c = 10
    GROUP BY L.c, mygeom.id
;
SELECT count(*),main_lidar_category   FROM grid_1m
WHERE id IN (SELECT id from temp_nullgrid)
GROUP BY main_lidar_category;

UPDATE grid_1m
SET main_lidar_category = 10
WHERE id IN (SELECT id from temp_nullgrid);

WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE main_lidar_category IS NULL)
    SELECT COUNT(*) as num, L.c, mygeom.id
    FROM l3d_1243_14_d L, mygeom
    WHERE st_contains(st_envelope(mygeom.geom), L.geom)
    GROUP BY L.c,mygeom.id
ORDER BY mygeom.id
;

-- on corrige main_lidar_category qui sont encore null à ce stade
-- il devrait rester quelques grilles en 15,12,16 je les passe en 2
-- on recupere les id de grilles 1m concernes dans table temp_nullgrid
-- et on update toutes ces grilles  main_lidar_category avec 2 (sol impermeable)
DROP TABLE temp_nullgrid;
WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE main_lidar_category IS NULL)
    SELECT COUNT(*) as num, L.c , mygeom.id
    INTO temp_nullgrid
    FROM l3d_1243_14_d L, mygeom
    WHERE st_contains(st_envelope(mygeom.geom), L.geom)
    --AND L.c = 10
    GROUP BY L.c, mygeom.id
;
SELECT count(*),main_lidar_category   FROM grid_1m
WHERE id IN (SELECT id from temp_nullgrid)
GROUP BY main_lidar_category;

UPDATE grid_1m
SET main_lidar_category = 2
WHERE id IN (SELECT id from temp_nullgrid);

-- on decide d'attribuer main_lidar_category des low point en sol impermeable
UPDATE grid_1m
SET main_lidar_category = 2
WHERE main_lidar_category = 7;

--- RESTE LES GRILLES OU ILS N Y A AUCUN POINT LIDAR
-- DANS CE CAS ON PREND LE MAIN_LIDAR DES GRILLES ADJACENTES
SELECT COUNT(*), main_lidar_category
FROM grid_1m
GROUP BY main_lidar_category
ORDER BY main_lidar_category;

WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE main_lidar_category IS NULL)
    SELECT COUNT(*) as num, mygeom.id
    FROM l3d_1243_14_d L, mygeom
    WHERE st_contains(st_envelope(mygeom.geom), L.geom)
    GROUP BY mygeom.id
ORDER BY mygeom.id
;
DROP TABLE temp_nullgrid;
WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE main_lidar_category IS NULL),
     -- avec les id de ces grilles ou on a pas de main_lidar_category
     -- on compte les valeurs distinctes de main_lidar_category autour
     myagg AS (SELECT mygeom.id, a.main_lidar_category, count(*) as num
               FROM grid_1m as a,
                    mygeom
               WHERE st_intersects((st_buffer(mygeom.geom, 0.00001)), a.geom)
                 AND a.main_lidar_category IS NOT NULL
               GROUP BY mygeom.id, a.main_lidar_category
               ORDER BY mygeom.id, num)
SELECT mytopcategory.*
INTO temp_nullgrid
FROM ( -- et on retient la categorie qui est la plus representee autour du la grille manquante
         SELECT distinct myagg.id,
                         myagg.num,
                         myagg.main_lidar_category,
                         rank() OVER (
                             partition by myagg.id
                             ORDER BY myagg.num DESC , myagg.main_lidar_category ASC
                             )
         FROM myagg
         ORDER BY myagg.id) mytopcategory
WHERE mytopcategory.rank < 2
ORDER BY mytopcategory.id;
;

-- on met a jour les quelques grilles avec main_lidar_category encore nulles
WITH myTopValFromGridVoisines AS (SELECT id,main_lidar_category FROM temp_nullgrid)
UPDATE grid_1m G
SET main_lidar_category = myTopValFromGridVoisines.main_lidar_category
FROM myTopValFromGridVoisines
WHERE G.id = myTopValFromGridVoisines.id;


SELECT COUNT(*), main_lidar_category
FROM grid_1m
GROUP BY main_lidar_category
ORDER BY main_lidar_category;

-- ET VOILA ON EST BON POUR main_lidar_category sur GRILLE 1m, plus de null
/*
 438862	2
389227	3
12870	4
171840	5
440985	6
923	9
293	10

 */