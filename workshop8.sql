CREATE TYPE route_intersect_type_v2 AS
   (distance double precision,
   istouching boolean,
   roadname character varying
   );

--id'si verilen rota
--ilgili noktanın 2 km yakınında ise (bu 2 km performans için veriyoruz tüm tablodaki 
--kayıtlara bakmaktansa yalnız 2 km çapında bir daire içinde kalan yollara baksın)
--uzaklığını ve bboxlarının birbirine değip değmediğini verir
CREATE OR REPLACE FUNCTION route_intersect_v2(
    int1 integer,
	lon double precision,
	lat double precision,
	distance double precision
    )
  RETURNS route_intersect_type_v2 AS
$BODY$
	DECLARE
		route1 geometry;
		returnVal route_intersect_type_v2;
		bbxDist double precision;
	BEGIN
		select geom, name from roads where ogc_fid = int1 into route1, returnVal.roadname;

		select st_distance(route1, st_setsrid(st_makepoint(lon, lat),4326))
		where
		st_dwithin(
			st_setsrid(st_makepoint(lon, lat),4326),
			route1,
			distance) 
		order by st_distance(route1, st_setsrid(st_makepoint(lon, lat),4326))
		limit 1
		into returnVal.distance;

		returnVal.istouching = false;

		select route1 <#> st_setsrid(st_makepoint(lon, lat),4326) into bbxDist;

		if bbxDist = 0 then
			returnVal.istouching = true;
		end if;		
		
		return returnVal;
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;

  select * from route_intersect_v2(1806,32.78981,39.95935,0.02);