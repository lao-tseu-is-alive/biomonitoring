#!/usr/bin/python3
import math
MIN_ID = 1
MAX_ID = 755000
SQL = """
WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE id > {id1} AND  id < {id2} ORDER BY 1),
myAgg AS (SELECT COUNT(*) as num, L.c, mygeom.id
FROM lidar_2015 L,mygeom
WHERE st_contains(st_envelope(mygeom.geom), L.geom)
GROUP BY L.c, mygeom.id)
UPDATE grid_1m G
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
WHERE G.id = mygeom.id;\n;
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
