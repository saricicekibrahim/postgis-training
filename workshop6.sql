
--noktaya 20 metre yakındaki yolun adını ve yolun
--bu noktaya en yakın noktasını getirir
select 
name, 
st_closestpoint(
	geom,
	st_geomfromtext('POINT(32.78981 39.95935)',4326)) 
	as geom
 from roads
where st_dwithin(geom,
st_geomfromtext('POINT(32.78981 39.95935)',4326),0.0002) 
limit 1