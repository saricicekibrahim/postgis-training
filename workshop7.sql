CREATE TYPE route_intersect_type_v1 AS
   (distance double precision,
   istouching boolean
   );
--idleri tanımlı iki yolun bboxları arasındaki uzaklığı döndüren fonksiyon
--uzaklık 0 ise istouching değerini true set eder
CREATE OR REPLACE FUNCTION route_intersect_v1(
    int1 integer,
    int2 integer)
  RETURNS route_intersect_type_v1 AS
$BODY$
	DECLARE
		route1 text;
		route2 text;
		returnVal route_intersect_type_v1;
	BEGIN
		select geom from roads where ogc_fid = int1 into route1;
		select geom from roads where ogc_fid = int2 into route2;

		select route1 <#> route2 into returnVal.distance;

		returnVal.istouching = false;
		if returnVal.distance = 0 then
		returnVal.istouching = true;
		end if;		
		
		return returnVal;
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;

  select route_intersect_v1(1806,13621);