--veritabanı oluşturuyoruz
create database workshop;

--postgis gereksinimlerini veritabanına ekliyoruz
--bunu çalıştırmadan önce ve sonra oluşturduğumz veritabanına bakalım
--functions, views ve tables bölümü tamamen boş olmalı
create extension postgis;
--bunu çalıştırdığımızda postgis eklentisi ile gelen tablo, funtions ve viewlwerin oluştuğuna emin olun
--spatial_ref_sys tablosu farklı projeksiyon bilgileri ve bunların srid bilgilerini tutar
--bu çalışmada coğrafi --> 4326 ve Google --> projeksiyonlarını kullanacağız

--spatialdata adında ve içinde geometry tipinde kolon içeren bir tablo oluşturuyoruz
CREATE TABLE spatialdata
(
	id serial NOT NULL,
	geom geometry,
	CONSTRAINT pkey PRIMARY KEY (id)
)

--bu tabloya veri girişi yapacağız
--önce poligon girişi yapacağız
--bunun için st_geomfromtext fonksiyonunu kullanacağız
insert into spatialdata (geom)
SELECT ST_GeomFromText('POLYGON((
43.747676 38.550777,
43.957789 38.452978,
43.668025 38.444374,
43.747676 38.550777
))',4326);

--şimdi bir point girişi yapacağız
--bunun için yine st_geomfromtext fonksiyonunu kullanacağız
insert into spatialdata (geom) 
select st_geomfromtext('POINT(37.010310 39.747250)',4326);

--bir line girişi yapalım
insert into spatialdata (geom) 
SELECT ST_GeomFromText('LINESTRING(26.809505 40.055404,29.462703 38.666675)',4326);

--spatial olamayan bir tabloyu spatial hale şu şekilde de getirebilirdik
--addgeometrycolumn fonksiyonu ile şema adı, tablo adı, geometri kolonu adı, 
--projeksiyon, obje tipi ve obje boyutu vererek ilgili kolonu oluşturabiliriz
SELECT AddGeometryColumn ('public','spatialdata','geom2',4326,'POINT',2);

--aynı klasördeki tr_iller backup dosyasını pg_restore kullanarak ya da 
--pgadminIII ile veritabanına sağ tuş tıklayıp restore işlemi ile yükleyelim

--alttaki sorgu ile spatialdata tablosundaki nokta objesinin yaklaşık 1 km yakınında illeri listeleyeceğiz
--st_dwithin fonksiyonuna iki geometri bir de mesafe girer, boolean bir değer döner
--bu foksiyon gist indexini kullanır bu yüzden çok performanslı bir sorgudur
--bunun yerine st_buffer ve st_intersects de kullanılabilir
--nokta objesini bulmak için st_geometrytype fonksiyonunu kullanıyoruz
--buradaki 0.001 değeri coğrafi projeksiyonda yaklaşık 1 km uzaklığa denk gelir
select iladi from tr_iller i, spatialdata s where st_dwithin(s.geom,i.geom,0.001)
and st_geometrytype(s.geom)='ST_Point';

--yine aynı noktaya 70 km yakınlıktaki illeri listeleyelim
--bu sefer mesafe için utm projeksiyon kullandık
--daha detaylı bilgi için şuraya bakabilirsiniz http://spatialreference.org/ref/epsg/wgs-84-utm-zone-37n/
--projeksiyon dönüşümü için st_transform fonksiyonunu kullanıyoruz
--bu projeksiyon ile metrik değerler kullanıyoruz yani 70 km için 70000 metre değeri giriyoruz
select iladi from tr_iller i, spatialdata s where 
st_dwithin(st_transform(s.geom,32637),st_transform(i.geom,32637),70000)
and st_geometrytype(s.geom)='ST_Point';

--poligon objesine değen illeri listeliyoruz
--bu sefer st_dwithin yerine st_intersects kullanalım
select iladi from tr_iller i, spatialdata s where st_intersects(s.geom,i.geom)
and st_geometrytype(s.geom)='ST_Polygon';

--Ankaraya komşu olan illeri listeliyoruz
--sorgu sonucunda Ankara'nın kendisi olmaması gerekiyor
--bir sorguda tüm iller diğerinde yalnız Ankara'yı alıyoruz 
--ve bu iki sorguda birbirine değenleri buluyoruz
select
tr.iladi
from
tr_iller tr,
tr_iller ank
where
tr.gid != ank.gid and
ank.iladi='Ankara' and
ST_Intersects(ank.geom, tr.geom)