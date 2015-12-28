--ilgili noktaya 2 km mesafedeki tüm yolların adını ve 
--noktaya olan uzaklıklarını listeler

CREATE OR REPLACE FUNCTION route_intersect_v3(
	lon double precision,
	lat double precision,
	distance double precision
    )
  RETURNS table(dist double precision, name character varying) AS
$BODY$
	DECLARE
		point geometry;
		bbxDist double precision;
	BEGIN
		select st_setsrid(st_makepoint(lon, lat),4326) into point;

		return query
		select st_distance(r.geom, point), r.name
		from roads r
		where
		st_dwithin(
			point,
			r.geom,
			distance);
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;

--uzaklığa göre sıralayarak listeliyoruz
  select * from route_intersect_v3(32.78981,39.95935,0.02) order by dist;