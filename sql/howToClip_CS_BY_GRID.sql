select clipped.id, clipped.no_eca, clipped_geom
from (
         select cs_bati_pol.id, cs_bati_pol.no_eca,
             (ST_Dump(ST_Intersection(cs_bati_pol.geom, grid_10m.geom))).geom clipped_geom
         from cs_bati_pol
              inner join grid_10m on ST_Intersects(cs_bati_pol.geom, grid_10m.geom)
        where grid_10m.id = 292
     ) as clipped
where ST_Dimension(clipped.clipped_geom) = 2;