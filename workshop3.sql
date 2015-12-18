select iladi from spatialdata s, tr_iller i 
where 
st_geometrytype(s.geom) = 'ST_Point'
and
st_x(s.geom) > st_xmin(i.geom);


select iladi, st_distance(s.geom,i.geom), s.geom <#> i.geom from spatialdata s, tr_iller i 
where 
st_geometrytype(s.geom) = 'ST_Point'
and
--s.geom <-> i.geom =0
s.geom && i.geom;



insert into spatialdata(geom)
select 
st_transform(
	st_setsrid(
		st_makepoint(
			st_x(
				st_transform(geom,900913))-10000,
			st_y(
				st_transform(geom,900913)) + 20000
				) 
				,900913)
				,4326)
from spatialdata where
st_geometrytype(geom) = 'ST_Point'


select st_centroid(geom) from tr_iller limit 5


select st_distance(r.geom, a.geom)
from tr_iller r, tr_iller a
where
r.iladi='Rize' and
a.iladi='Ankara'


select st_distance(
st_transform(st_centroid(r.geom),900913), 
st_transform(st_centroid(a.geom),900913)
)/1000 || ' km'
from tr_iller r, tr_iller a
where
r.iladi='Rize' and
a.iladi='Ankara'

select 
i.iladi,
st_distance(a.geom,i.geom) as d from tr_iller i, tr_iller a
where 
a.iladi='Ankara'
order by d desc
limit 1