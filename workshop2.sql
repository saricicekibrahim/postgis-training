CREATE TABLE spatialdata2
(
id serial NOT NULL,
geom geometry,
CONSTRAINT spatialdata2_pkey PRIMARY KEY (id)
)

alter table spatialdata2 add column geom2 geometry;

insert into spatialdata2 (geom)
select st_setsrid(st_makeline(st_makepoint(26.809505,40.055404),
st_makepoint(29.462703,38.666675)),4326)

select st_srid(geom) from spatialdata2
update spatialdata2 set geom =st_setsrid(geom,432)

update spatialdata2 set geom2 = st_transform(geom,900913)

select st_isvalid(geom) from tr_iller where 
st_isvalid(geom) = 'f'

select st_astext(st_startpoint(geom)),
st_x(st_startpoint(geom)),
st_y(st_startpoint(geom))
 from spatialdata where
st_geometrytype(geom) = 'ST_LineString'


select iladi, st_npoints(geom) from tr_iller limit 5

select st_astext(st_pointn(geom,1)),
 st_astext(st_geometryn(geom,1)) from spatialdata

 select st_dwithin(
	st_endpoint(geom),
		st_geomfromtext('POINT(29.461703 38.666675)',4326)
	,0.005)
 from spatialdata
 where
st_geometrytype(geom) = 'ST_LineString'


select st_intersects(
	st_buffer(st_endpoint(geom), 0.005),
		st_geomfromtext('POINT(29.461703 38.666675)',4326)
	)
 from spatialdata
 where
st_geometrytype(geom) = 'ST_LineString'