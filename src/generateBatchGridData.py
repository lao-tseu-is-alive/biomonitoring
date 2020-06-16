#!/usr/bin/python3
import math
MIN_ID = 8500
MAX_ID = 14500
SQL = """
WITH mygeom AS (SELECT id, geom FROM grid_10m WHERE id > {id1} AND  id < {id2} ORDER BY 1),
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
WHERE G.id = mygeom.id;\n
"""
width = MAX_ID - MIN_ID
STEP_SIZE = 10
cols = math.floor(width / STEP_SIZE)
print("\n--### BATCH GENERATION ### ")
print("--# start at \t: {minx}".format(minx=MIN_ID))
print("--# end at   \t: {maxid}".format(maxid=MAX_ID))
print("--# step is  \t: {s}".format(s=STEP_SIZE))
for i in range(cols):
    x = MIN_ID + (i * STEP_SIZE)
    print(SQL.format(id1=x-1, id2=x+STEP_SIZE))

x = MIN_ID + (cols * STEP_SIZE)
print(SQL.format(id1=x-1, id2=MAX_ID+1))
