#!/usr/bin/python3
import math
MIN_ID = 1
MAX_ID = 750000
#MAX_ID = 1455000
SQL = """
WITH mygeom AS (SELECT id, geom FROM grid_1m WHERE id > {id1} AND  id < {id2} ORDER BY 1),
     myAgg AS (SELECT COUNT(*) as num, min(z) as minZ, max(z) as maxZ,avg(z) as avgZ,  mygeom.id
               FROM l3d_1243_14_d L,
                    mygeom
               WHERE st_contains(st_envelope(mygeom.geom), L.geom)
               GROUP BY mygeom.id)
UPDATE grid_1m G
SET densite_lidar_2012=(SELECT num FROM myAgg WHERE myAgg.id = G.id),
    altitude_min=(SELECT minZ FROM myAgg WHERE myAgg.id = G.id),
    altitude_max=(SELECT maxZ FROM myAgg WHERE myAgg.id = G.id),
    altitude_mean=(SELECT avgZ FROM myAgg WHERE myAgg.id = G.id)
FROM myAgg,
     mygeom
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
