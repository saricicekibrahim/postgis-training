--bir tablo daha oluşturuyoruz
CREATE TABLE spatialdata2
(
	id serial NOT NULL,
	geom geometry,
	CONSTRAINT spatialdata2_pkey PRIMARY KEY (id)
)

--bu tabloya bir geometry kolonu daha ekliyoruz
alter table spatialdata2 add column geom2 geometry;

--spatialdata2 tablosuna bir line objesi ekliyoruz
--bu sefer st_makeline kullanıyoruz
--line objesini oluşturan noktalar için de st_makepoint kullanıyoruz
--yalnız st_make ile başlayan foksiyonlar projeksiyon tanımlamaz
--oluşturduğunuz objenin projeksiyonu 0 görünür
--bu durumu yaşamamak için st_setsrid fonksiyonu kullanıyoruz
--stsetsrid bir projeksiyon dönüşümü yapmaz! sadece projeksiyon tanımlama sağlar
insert into spatialdata2 (geom)
select st_setsrid(st_makeline(st_makepoint(26.809505,40.055404),
st_makepoint(29.462703,38.666675)),4326)

--her bir objenin projeksiyonunu öğrenmek için şu sorguyu çalıştırabilirsiniz
select st_srid(geom) from spatialdata2

--yine tanımsız projeksiyonu olan objeleri şu şekilde updata edebilirsiniz
--burada bir kez daha hatırlatayım projeksiyon dönüşümü için st_transform kullanılır
--burada sadece set ediyoruz
update spatialdata2 set geom =st_setsrid(geom,432)

--tanımlı bir projeksiyonu olan objeleri projeksiyon dönüşümü için şu sorguyu kullnaalım
update spatialdata2 set geom2 = st_transform(geom,900913)

--objelerin geometrik olarak doğru-yanlış tanımlandığını st_isvalid fonksiyonu ile anlıyoruz
--detaylı bilgi için şu linke bakılabilir http://postgis.net/docs/using_postgis_dbmanagement.html#OGC_Validity
--bu fonksiyon boolean bir değer döndürür
select st_isvalid(geom) from tr_iller where 
st_isvalid(geom) = false

--spatialdata tablosunda line objesinin başlangıç noktasını text olarak alıyoruz
--yalnız enlem ve yalnız boylam bilgilerini de st_x ve st_y ile alıyoruz
--başlangıç noktası için st_startpoint ya da st_pointn fonksiyonu ile 1. noktaya ulaşabiliriz
select st_astext(st_startpoint(geom)),
st_x(st_startpoint(geom)),
st_y(st_startpoint(geom))
from spatialdata where
st_geometrytype(geom) = 'ST_LineString'

--iller tablosunda 5 kaydın toplam nokta sayısına ulaşıyoruz
--line ve polgonlar noktalardan oluşur
--noktaları birleştiren çizgi başlangıç noktasına dönerse bir poligon oluşur
--bir objedeki nokta sayısı arttıkça obje üzerinde yapılan işlemler zorlaşır
select iladi, st_npoints(geom) from tr_iller limit 5

--spatial tablosundaki tüm objelerin ilk noktası ve ilk geometrisini alıyoruz
--st_pointn yalnız line objeleri için çalışır
--st_geometryn de multigeometri objeler için çalışır
--her bir obje tek geometri kapsadığı için objenin kendisini verir
select st_astext(st_pointn(geom,1)),
 st_astext(st_geometryn(geom,1)) from spatialdata

--koordinatları altta tanımlı nokta
--spatialdata tablosundaki line objesinin bitiş noktasına
--yaklaşık 500 m yakınlıkta mı sorgusu
--line objesi bir rota diyelim. kullanıcı bu rotayı bitirdi mi bitirmedi mi bu şekilde anlayabiliriz
 select st_dwithin(
	st_endpoint(geom),
		st_geomfromtext('POINT(29.461703 38.666675)',4326)
	,0.005)
 from spatialdata
 where
st_geometrytype(geom) = 'ST_LineString'

--yukarıdaki sorgunun aynısı st_buffer ve st_intersects içerecek şekilde alttaki yapalım
--geometri kolonunda bir gist index tanımlıysa yukarıdaki sorgu bu indexi kullanır, alttaki sorgu kullanmaz!
--line objesinin son noktasına yaklaşık 500 m'lik bir tampon tanımlıyoruz
--tanımlı nokta bu tampona değiyor mu sorgusu
select st_intersects(
	st_buffer(st_endpoint(geom), 0.005),
		st_geomfromtext('POINT(29.461703 38.666675)',4326)
	)
 from spatialdata
 where
st_geometrytype(geom) = 'ST_LineString'