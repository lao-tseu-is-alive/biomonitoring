#!/usr/bin/python3
import math
MIN_X = 536875
MIN_Y = 153000
MAX_X = 538330
MAX_Y = 154000
width = MAX_X - MIN_X
height = MAX_Y - MIN_Y
# 1 hectare     = 1 ha = 100 are = 10 000 m2, soit l'aire d'un carré de 100 mètres de côté
#GRID_SIZE = 100
# 0.01 hectare  = 0.01 ha = 1 are = 100 m2, soit l'aire d'un carré de 10 mètres de côté
GRID_SIZE = 1
cols = math.floor(width / GRID_SIZE)
rows = math.floor(height / GRID_SIZE)
print("\n--### GRID GENERATION ### ")
print("--# start at (x,y) \t: {minx},{miny}".format(minx=MIN_X, miny=MIN_Y))
print("--# height x width \t: {h}x{w}".format(w=width, h=height))
print("--# grid size is  \t: {g}x{g}m".format(g=GRID_SIZE))
print("--# rows x cols   \t: {r}x{c}".format(r=rows, c=cols))
for i in range(rows):
    y = MIN_Y  + (i * GRID_SIZE)
    print("--row : {r}, y = {y} ".format(r=i, y=y))
    for j in range(cols):
        x = MIN_X + (j * GRID_SIZE)
        print("INSERT INTO grid_1m (geom) VALUES (ST_MakeEnvelope({x}, {y}, {x2}, {y2}, 21781) );"
              .format(x=x,y=y,x2=x+GRID_SIZE,y2=y+GRID_SIZE))

