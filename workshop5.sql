  CREATE TYPE revgeo_type_v2 AS
   (roadname character varying,
   landusename character varying);

CREATE OR REPLACE FUNCTION revgeo_v2(
    lon double precision,
    lat double precision)
  RETURNS revgeo_type_v2 AS
$BODY$
	DECLARE
		address revgeo_type_v2;
		vBbox text;
		vGeom text;
		buffer text;
		bufferD double precision;
		insideBuffer text;
		lbLon double precision;
		lbLat double precision;
		rtLon double precision;
		rtLat double precision;
		isInside text;
		distanceText text;
		byDistanceBoxCollapses text;
		boxCollapses text;
	BEGIN
		buffer := '0.001'; --100 m
		insideBuffer := '0.002'; --200 m
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
		isInside := ' where st_dwithin(' || 'geom, ''' || vGeom || ''',' || insideBuffer ||') limit 1';
		distanceText := 'st_distance(geom, ''' || vGeom || ''') dist';
		boxCollapses := ' where geom && ''' || vBbox || ''' limit 1';

			--road
			execute 'select name, ' 
			|| distanceText || ' from roads' ||  
			byDistanceBoxCollapses 
			into address.roadname;


			--landuse
			execute 'select name from landuse' ||  
			isInside 
			into address.landusename;

		return address;
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;

  select roadname, landusename from revgeo_v2(32.78981,39.95935);
  select * from revgeo_v2(32.78981,39.95935);