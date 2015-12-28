CREATE TYPE revgeo_type_v1 AS
   (roadname character varying);

CREATE OR REPLACE FUNCTION revgeo_v1(
    lon double precision,
    lat double precision)
  RETURNS revgeo_type_v1 AS
$BODY$
	DECLARE
		address revgeo_type_v1;
		vBbox text;
		vGeom text;
		buffer text;
		bufferD double precision;
		lbLon double precision;
		lbLat double precision;
		rtLon double precision;
		rtLat double precision;
		distanceText text;
		byDistanceBoxCollapses text;
	BEGIN
		buffer := '0.001'; --100 m
		bufferD := cast(buffer as double precision);

		lbLon := lon - bufferD;
		lbLat := lat - bufferD;
		rtLon := lon + bufferD;
		rtLat := lat + bufferD;

		select ST_GeomFromText('POINT('||lon||' '||lat||')', 4326) 
		into vGeom;
		
		select ST_SetSRID(('BOX('||lbLon||' '||lbLat||','||rtLon||' '||rtLat||')')::box2d, 4326) 
		into vBbox;

		byDistanceBoxCollapses := ' where geom && ''' || vBbox || ''' order by dist limit 1';
		distanceText := 'st_distance(geom, ''' || vGeom || ''') dist';

			--road
			execute 'select name, ' 
			|| distanceText || ' from roads' ||  
			byDistanceBoxCollapses 
			into address.roadname;

		return address;
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;

  select revgeo_v1(32.78981, 39.95935);
