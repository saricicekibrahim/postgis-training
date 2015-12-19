--spatialdata tablosundaki nokta objesinin enlemi hangi 
--illerin minimum enleminden daha büyük sorgusu
--yani ilgili noktanın batısındaki llerin adını listeleyelim
select iladi from spatialdata s, tr_iller i 
where 
st_geometrytype(s.geom) = 'ST_Point'
and
st_x(s.geom) > st_xmin(i.geom);

--spatialdata tablosundaki nokta objesi hangi ilin bbox'ı ile kesişiyor
--bu noktanın ile uzaklığı nedir ve noktanın ilin bbox'ına uzaklığı nedir sorgusu
--bbox objenin bounding box'ı demektir. Yani objeyi tam içine alan dörtgendir
--objelerin tüm noktalarını işleme alacağına objeyi kapsayan dörtgen üzerinden işlem yapmak her zaman daha hızlıdır
--&& operatörü iki objenin bbox birbirine değiyor mu sorgular
--<#> operatörü de iki objenin bbox ları arasındaki mesafeyi verir
--buradaki mesafe coğrefi projeksiyonda ve derece cinsindendir.
select iladi, 
st_distance(s.geom,i.geom), 
s.geom <#> i.geom from spatialdata s, tr_iller i 
where 
st_geometrytype(s.geom) = 'ST_Point'
and
s.geom && i.geom;

--spatialdata tablosundaki noktanın projeksiyonunu Google projeksiyonu yapıyoruz
--enlemini 10 km batıya, boylamını 20 km kuzeye taşıyacak bir başka nokta oluşturuyoruz
--bu noktanın projeksiyonunu st_makepoint tanımlamadığı için st_setsrid ile Google projeksiyon olarak belirliyoruz
--sonra st_transform işlemi ile noktayı tekrar coğrafi projeksiyona dönüştürüp,
--spatialdata tablosuna insert ediyoruz
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

--iller tablosundaki 5 kaydın ağırlık noktası sorgusu
--st_centroid bir objenin ağırlık merkezini nokta olarak verir
--ağırlık merkezi bir çizgi ya da bir poligonun içinde, ya da sınırında olmayabilir!
select st_centroid(geom) from tr_iller limit 5

--iller tablosunda Rize sınırının Ankara sınırına uzaklığını veren sorguyu çalıştıralım
select st_distance(r.geom, a.geom)
from tr_iller r, tr_iller a
where
r.iladi='Rize' and
a.iladi='Ankara'

--iller tablosunda Ankara'nın merkezinin Rizenin merkezine Google projeksiyonda
--uzaklığını veren sorgu
select st_distance(
st_transform(st_centroid(r.geom),900913), 
st_transform(st_centroid(a.geom),900913)
)/1000 || ' km'
from tr_iller r, tr_iller a
where
r.iladi='Rize' and
a.iladi='Ankara'

--iller tablosunda Ankara'nın tüm illere olan uzaklığını sorguluyoruz
--uzaklığa göre tersten sıralıyoruz ve ilk kaydı alıyoruz
--böylece Ankara'ya en uzak olan ilin adı ve derece cinsinden Ankara'ya uzaklığını buluyoruz
select 
i.iladi,
st_distance(a.geom,i.geom) as d from tr_iller i, tr_iller a
where 
a.iladi='Ankara'
order by d desc
limit 1