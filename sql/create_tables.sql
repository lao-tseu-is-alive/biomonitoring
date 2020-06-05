create table l3d_1243_14_d
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
comment on table l3d_1243_14_d is 'lidar 2012 data from 1243-14-d_color_def.las';
-- lasinfo 1243-14-d_color_def.las >1243-14-d_color_def.lasinfo.txt
-- las2pg 1243-14-d_color_def.las  --parse xyzRGBic --stdout | psql -c "copy l3d_1243_14_d from stdin with binary" biomonitoring
-- should give back number of rows:
-- COPY 43362150
-- verify that 2d bounding box is equal to lasinfo result 1243-14-d_color_def.lasinfo.txt
SELECT
       MIN(x) as min_x, MIN(y) as min_y,
       MAX(x) as max_x, MAX(y) as max_y
FROM l3d_1243_14_d LIMIT 10;

-- add a geometry column
SELECT addgeometrycolumn('l3d_1243_14_d', 'geom', 21781, 'POINT', 2);
UPDATE l3d_1243_14_d SET geom = ST_SetSRID(st_makepoint(x, y ), 21781);
--- 43362150 rows affected in 1 m 45 s 972 ms

-- create spatial index
CREATE INDEX l3d_1243_14_d_geom_idx ON l3d_1243_14_d USING gist(geom);
--  completed in 7 m 56 s 14 ms

-- 1 hectare     = 1 ha = 100 are = 10 000 m2, soit l'aire d'un carré de 100 mètres de côté
-- create 100m grid table
create table grid_100m
(
	id serial not null,
	n2_sol_non_permeable int,
	n3_sol_permeable int,
	n4_vegetation_basse int,
    n5_vegetation int,
    n6_batiments int,
    n9_eau int,
    main_lidar_category int,
    canopee_percent int,
    surf_vegetalisees_percent int,
    pleine_terre_percent int,
    sol_libre_percent int,
    surf_permeable_percent int,
    arbres_nombre int,
    surf_arbustive_percent int,
    surf_verte_prive_percent int,
    surf_verte_public_percent int,
    zone_forestiere_percent int,
    zone_verdure_protege_percent int,
    surf_batie_percent int,
    altitude_min double precision,
    altitude_max double precision,
    altitude_mean double precision,
    altitude_median double precision
);
create unique index grid_100m_id_uindex 	on grid_100m (id);
alter table grid_100m add constraint grid_100m_pk primary key (id);
-- add a geometry column
SELECT addgeometrycolumn('grid_100m', 'geom', 21781, 'POLYGON', 2);
--use insertGrid.py to generate polygons like this one for all area
 INSERT INTO grid_100m (geom) VALUES (ST_MakeEnvelope(536875, 153000, 536975, 153100, 21781));
CREATE INDEX grid_100m_geom_idx ON grid_100m USING gist(geom);
VACUUM ANALYSE grid_100m;

create table grid_10m
(
	id serial not null
		constraint grid_10m_pk
			primary key,
	n2_sol_non_permeable integer,
	n3_sol_permeable integer,
	n4_vegetation_basse integer,
	n5_vegetation integer,
	n6_batiments integer,
	n9_eau integer,
	main_lidar_category integer,
	canopee_percent integer,
	surf_vegetalisees_percent integer,
	pleine_terre_percent integer,
	sol_libre_percent integer,
	surf_permeable_percent integer,
	arbres_nombre integer,
	surf_arbustive integer,
	surf_verte_prive integer,
	surf_verte_public integer,
	surf_zone_forestiere integer,
	surf_zone_verdure_protege integer,
	surf_batie integer,
	altitude_min double precision,
	altitude_max double precision,
	altitude_mean double precision,
	altitude_median double precision,
	geom geometry(Polygon,21781),
	n2_sol_non_permeable_2015 integer,
	n3_sol_permeable_2015 integer,
	n5_vegetation_2015 integer,
	n6_batiments_2015 integer,
	n9_eau_2015 integer,
	main_lidar_category_2015 integer
);

alter table grid_10m owner to postgres;

create unique index grid_10m_id_uindex	on grid_10m (id);

create index grid_10m_geom_idx	on grid_10m (geom);


create unique index grid_10m_id_uindex 	on grid_10m (id);
alter table grid_10m add constraint grid_10m_pk primary key (id);

-- add a geometry column
SELECT addgeometrycolumn('grid_10m', 'geom', 21781, 'POLYGON', 2);


SELECT ST_AsText( ST_MakeEnvelope(10, 10, 11, 11, 21781) );

CREATE EXTENSION plpython3u;
-- check that python3 lang works
CREATE FUNCTION pymax (a integer, b integer)
  RETURNS integer
AS $$
  if a > b:
    return a
  return b
$$ LANGUAGE plpython3u;
-- just use this function
SELECT pymax(-10, 6);

DO $$
    # PL/Python code
    import plpy
    res = plpy.execute('SELECT x,y FROM l3d_1243_14_d LIMIT 10;', 5)
    plpy.log(res[0]['x'])
$$ LANGUAGE plpython3u;

