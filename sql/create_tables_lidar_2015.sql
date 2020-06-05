create table lidar_2015_2537_1153
(
    x double precision,
    y double precision,
    z double precision,
    r integer,
    g integer,
    b integer,
    i integer,
    c integer
);
comment on table lidar_2015_2537_1153 is 'lidar 2015 data from 2537_1153_MN03.las';
-- lasinfo 1243-14-d_color_def.las >1243-14-d_color_def.lasinfo.txt
-- time las2pg 2537_1153_MN03.las --parse xyzRGBic --stdout | psql -c "copy lidar_2015_2537_1153 from stdin with binary" biomonitoring
-- COPY 12518289
-- real	0m11.240s
-- verify that 2d bounding box is equal to lasinfo result 1243-14-d_color_def.lasinfo.txt
SELECT
       MIN(x) as min_x, MIN(y) as min_y,
       MAX(x) as max_x, MAX(y) as max_y
FROM lidar_2015_2537_1153 LIMIT 10;

-- add a geometry column
SELECT addgeometrycolumn('lidar_2015_2537_1153', 'geom', 21781, 'POINT', 2);
UPDATE lidar_2015_2537_1153 SET geom = ST_SetSRID(st_makepoint(x, y ), 21781);
--- 43362150 rows affected in 1 m 45 s 972 ms
-- create spatial index
CREATE INDEX lidar_2015_2537_1153_geom_idx ON lidar_2015_2537_1153 USING gist(geom);
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
create table lidar_2015_2536_1153
(
    x double precision,
    y double precision,
    z double precision,
    r integer,
    g integer,
    b integer,
    i integer,
    c integer
);
comment on table lidar_2015_2536_1153 is 'lidar 2015 data from 2536_1153_MN03.las';
-- postgres@vortex:/tmp$ time las2pg 2536_1153_MN03.las --parse xyzRGBic --stdout | psql -c "copy lidar_2015_2536_1153 from stdin with binary" biomonitoring
-- COPY 12949352
--  real	0m11.302s
-- verify that 2d bounding box is equal to lasinfo result 1243-14-d_color_def.lasinfo.txt
SELECT
       MIN(x) as min_x, MIN(y) as min_y,
       MAX(x) as max_x, MAX(y) as max_y
FROM lidar_2015_2536_1153 LIMIT 10;

-- add a geometry column
SELECT addgeometrycolumn('lidar_2015_2536_1153', 'geom', 21781, 'POINT', 2);
UPDATE lidar_2015_2536_1153 SET geom = ST_SetSRID(st_makepoint(x, y ), 21781);
--- 12949352 rows affected in 30 s 261 ms

-- create spatial index
CREATE INDEX lidar_2015_2536_1153_geom_idx ON lidar_2015_2536_1153 USING gist(geom);
--   completed in 2 m 23 s 134 ms

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
create table lidar_2015_2538_1153
(
    x double precision,
    y double precision,
    z double precision,
    r integer,
    g integer,
    b integer,
    i integer,
    c integer
);
comment on table lidar_2015_2538_1153 is 'lidar 2015 data from 2538_1153_MN03.las';
-- time las2pg 2536_1153_MN03.las --parse xyzRGBic --stdout | psql -c "copy lidar_2015_2536_1153 from stdin with binary" biomonitoring
-- COPY 12949352
--  real	0m11.302s
-- verify that 2d bounding box is equal to lasinfo result 1243-14-d_color_def.lasinfo.txt
SELECT
       MIN(x) as min_x, MIN(y) as min_y,
       MAX(x) as max_x, MAX(y) as max_y
FROM lidar_2015_2538_1153 LIMIT 10;

-- add a geometry column
SELECT addgeometrycolumn('lidar_2015_2538_1153', 'geom', 21781, 'POINT', 2);
UPDATE lidar_2015_2538_1153 SET geom = ST_SetSRID(st_makepoint(x, y ), 21781);
--- 15886869 rows affected in 32 s 858 ms

-- create spatial index
DROP INDEX lidar_2015_2538_1153_geom_idx;
CREATE INDEX lidar_2015_2538_1153_geom_idx ON lidar_2015_2538_1153 USING gist(geom);
--  completed in 2 m 52 s 846 ms
