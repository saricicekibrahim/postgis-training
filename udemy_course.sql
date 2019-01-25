-- bu dokuman udemy'de postgis kursundaki tüm sql leri kapsamaktadır
-- https://www.udemy.com/postgis-egitimi-turkce-postgis-in-turkish

create extension postgis;

--postgis versiyon ve kullandığı kütüphane ersiyonları gösterirselect PostGIS_Full_Version();

--postgis versiyon gösteririselect PostGIS_Version();

--id ve geometri kolonu içeren bir tablo oluşturdukcreate table spatialdata(    id serial NOT NULL,    geom geometry,    CONSTRAINT spatialdata_pkey PRIMARY KEY (id));

--addgeometrycolumn fonksiyonu ile public şemasında, spatialdata tablosuna, adı geom2 olan, --projeksiyonu yalnız coğrafi koordinatta (4326), 2 boyutlu noktaları kabul eden kolon ekledikSELECT AddGeometryColumn ('public','spatialdata','geom2',4326,'POINT',2);

------------------------------------------

--GEOMTRY CONSTURCTORS

--geomfromtext ile nokta olusturmainsert into spatialdata (geom)select st_geomfromtext('POINT(32.8618697 39.9090847)',4326);

--makepoint ile nokta olusturma ve setsrid ile projeksiyonunu tanımlamainsert into spatialdata (geom)select st_setsrid(            st_makepoint(32.8618697,39.9090847),4326        )--geojson'dan geometri olusturmainsert into spatialdata (geom)select st_geomfromgeojson('{"type":"Point","coordinates":[32.7703187,39.9449081]}')

--kml'den geometri olusturmainsert into spatialdata (geom)select st_geomfromkml('<Point><coordinates>32.770318699999997,39.944908099999999</coordinates></Point>');

--makeline ile çizgi oluşturdukinsert into spatialdata (geom)select st_makeline(st_geomfromtext('POINT(32.8618697 39.9090847)',4326), st_geomfromtext('POINT(33.8618697 39.9090847)',4326))

--makepolygon ile poligon oluşturdukinsert into spatialdata (geom)    SELECT ST_MakePolygon(ST_GeomFromText('LINESTRING(75.15 29.53 1,77 29 1,77.6 29.5 1, 75.15 29.53 1)'));    

------------------------------------------

--GEOMETRY OUTPUTS

--wkt formatında geomtri çıktısı verirselect st_astext(geom) from spatialdata;

--geojson formatında geomtri çıktısı verirselect st_asgeojson(geom) from spatialdata;

--kml formatında çıktı verir, kml için projeksiyon bilgisi tanımlanmış olmalıselect st_askml(geom) from spatialdata where st_srid(geom) = 4326;------------------------------------------

--GEOMETRY ACCESSORS

--geomtri tiplerini listeleyelimselect st_geometrytype(geom) from spatialdata;

--startpoint değeri linestring için çalışır.--postgis sayfasından hangi fonksiyonun hangi geometri tipleri için çalıştığı görülebilir.--yalnız linestring olanlar için cevap döner diğerleri null gelirselect st_startpoint(geom) from spatialdata;

--yalnız line olan objeleri listeleyip, bunların başlangıç ve bitiş x,y bilgilerine eriştikselect st_x(st_endpoint(geom)) bitisX,    st_y(st_endpoint(geom)) bitisY,    st_x(st_startpoint(geom)) baslangicX,    st_y(st_startpoint(geom)) baslangicY from spatialdata where st_geometrytype(geom)='ST_LineString';

--projeksiyonu coğrafi olan dışındakileri listeledik select st_srid(geom) from spatialdata where st_srid(geom) != 4326;

--geometri uygun üretilmiş mi kontrolü, cevap t = uygun, f = uygun değil dönerselect st_isvalid(st_geomfromtext(('POLYGON((0 0, 1 1, 1 2, 1 1, 0 0))')));

--geometri neden uygun değil sorgususelect st_isvalidreason(st_geomfromtext(('POLYGON((0 0, 1 1, 1 2, 1 1, 0 0))')));

--postgres özelliklerinden castingselect '2'::text,'2'::integer, '2'::float;

--text'i geomtriye cast edebilirimselect 'LINESTRING(0 0, 1 1, 2 2)'::geometry

--bir line'ın istenen noktasına ulaşımselect st_pointn('LINESTRING(0 0, 1 1, 2 2)'::geometry,3);

--bir line'ın istenen noktasındaki x değeriselect st_x(st_pointn('LINESTRING(0 0, 1 1, 2 2)'::geometry,2));

--bir geometrinin kaç noktadan oluştuğunu verirselect st_npoints('LINESTRING(0 0, 1 1, 2 2)'::geometry);

--bir multi objenin n'inci istenen geometrisini verirselect ST_GeometryN(st_geomfromtext('MULTIPOINT(1 2,3 4,5 6,8 9)'), 2);

--bir multipointin 2.noktasının hangi geometri tipinde olduğunu sorguladık.select st_geometrytype(ST_GeometryN(st_geomfromtext('MULTIPOINT(1 2,3 4,5 6,8 9)'), 2));

--bir poligonun bbox koordinatlarına ulaşımselect st_xmin(geom),    st_ymin(geom),    st_xmax(geom),    st_ymax(geom) from spatialdata where st_geometrytype(geom) = 'ST_Polygon' limit 1;

--bir poligonun bbox'ını tabloya yazdırdıkinsert into spatialdata(geom)select st_envelope(geom) from spatialdata where st_geometrytype(geom) = 'ST_Polygon' limit 1

------------------------------------------

--GEOMETRY EDITORS

--3 boyutlu geometrileri 2 boyutlu hale yani z değerleri yok olmuş hale getirdikselect st_astext(st_force2d('POINT(32 36 0)'::geometry));

--tabloda projeksiyon bilgisi set edilmemiş değerleri set ettik--sadece set ettik bir projeksiyon dönüşümü yapmadık!update spatialdata set geom = st_setsrid(geom,4326) where st_srid(geom) =0;

--tabloda projeksiyonu set edilmemeiş veri var mı konrol edelimselect st_srid(geom) from spatialdata;

--tablodaki bir poligon objesini 1 derece x, 0.5 derece y ekenin kaydırıp tabloya yazdıkinsert into spatialdata(geom)select st_translate(geom, 1, 0.5) from spatialdata where st_geometrytype(geom)='ST_Polygon' limit 1;

--tablodaki coğrafi projeksiyon veriyi google projeksiyona dönüştürdükselect st_transform(geom,3857) from spatialdata;

--farklı projeksiyonlarda x değerleri değişebilir bunu gösterdik.--coğrafide derece iken google'da metrik değerler elde ettik.select st_x(geom), st_x(st_transform(geom,3857)) from spatialdata where st_geometrytype(geom) = 'ST_Point';

--tabloya geometri tipinde bir kolon daha ekledik alter table spatialdata add column geom3 geometry;

--yeni eklenen kolonu google projeksiyonda veri girdikupdate spatialdata set geom3 = st_transform(geom,3857);

--tablodaki iki kolonun projeksiyonalrına baktıkselect st_srid(geom), st_srid(geom3) from spatialdata;

--index ekledikcreate index spatialdata_gix ON spatialdata USING GIST (geom);

--GEOMETRY OPERATORS

--Ankara ve Afyon coğrafi komşu değil ama bbox ları birbirine değiyorselect'evet değiyor'from tr_iller ank, tr_iller afywhere ank.geom && afy.geomand ank.iladi='Ankara'and afy.iladi='Afyonkarahisar'

--Ankara Bboxı Afyonun sağındaselect'evet Ankara Afyonun sağında'from tr_iller ank, tr_iller afywhere ank.geom &> afy.geomand ank.iladi='Ankara'and afy.iladi='Afyonkarahisar'

--Muğlanın Bboxı Ankaranın tamamen solundaselect'evet Muğla Ankara-nın tamamen solunda'from tr_iller ank, tr_iller mugwhere ank.geom >> mug.geomand ank.iladi='Ankara'and mug.iladi='Muğla'

--Ankaraya en yakın il operator distance ile explainexplain analyseselect otr.iladifrom tr_iller ank, tr_iller otrwhere ank.iladi='Ankara'and otr.iladi!='Ankara'order by otr.geom <-> ank.geom limit 1;

--Ankaraya en yakın il st_distance ile explainexplain analyseselect otr.iladifrom tr_iller ank, tr_iller otrwhere ank.iladi='Ankara'and otr.iladi!='Ankara'order by st_distance(otr.geom,ank.geom) limit 1;

--SPATIAL RELATIONSHIPS AND MEASUREMENTS

--tüm illerin merkez noktasının x değeriselect st_x(st_centroid(geom)) from tr_iller;

--tüm illerin ağırlık merkezine nokta koydukselect iladi,st_centroid(geom) into il_orta from tr_iller;

--tablodaki isim ve alanlarını getirdiselect name,st_area(geom) from landuse;

--derece cinsinden toplam alanselect sum(st_area(geom)) from landuse;

--km2 cinsinden toplam alanselect 'toplam alan = ' || sum(st_area(st_transform(geom,3857)))/1000/1000 || ' km2' from landuse;

--yolları uzunluğuna göre büyükten küçüğe sıralnmış en uzun 5 yolselect name, st_length(geom) from roads where name is not null order by st_length(geom) desc limit 5;

--bir nokta hangi ile değiyor sorgusuexplain analyseselect * from tr_illerwhere st_intersects(geom, st_geomfromtext('POINT(32.9 39.9)',4326));

--bir nokta hangi ilin 0.00000000001 derece yakınındaexplain analyseselect * from tr_illerwhere st_dwithin(geom, st_geomfromtext('POINT(32.9 39.9)',4326),0.00000000001);

--bir nokta hangi ilin 0.5 derece yakınındaselect st_dwithin(geom, st_geomfromtext('POINT(32.9 39.9)',4326),0.5),* from tr_illerwhere st_dwithin(geom, st_geomfromtext('POINT(32.9 39.9)',4326),0.5);

--Ankaraya komşu olmayan (hiç bir sınırı değmeyen) illeri listeledikselect tr.* from tr_iller ank, tr_iller trwhere st_disjoint(tr.geom,ank.geom)and ank.iladi='Ankara';

--içerisinde nokta olan alanları listeledik ve nokta sayısını bir kolona yazdırıp yeni tablo oluşturdukselect count(1),l.ogc_fid,l.name, l.geom into landuse_point_theme from landuse l, mypoints p where st_intersects(l.geom,p.geom) group by l.ogc_fid;

--11 id li alandaki yolların toplam uzunluğunu buldukselect sum(st_length(r.geom)) from roads r, landuse l where st_dwithin(r.geom,l.geom,0.0000000001) and l.ogc_fid=11;

--11 id li alana değen ve dışarı taşan yolları bir tabloya yazdıkselect r.name, r.geom into cross_roads from roads r, landuse l where st_crosses(r.geom,l.geom) and l.ogc_fid=11;

--11 id li alanın tamamen içinde olan yolları bir tabloya yazdıkselect r.name, r.geom into contain_roads from roads r, landuse l where st_contains(l.geom,r.geom) and l.ogc_fid=11;

--GEOMETRY PROCESSING FUNCTIONS

--bir noktaya 0.5 derece buffer verip hangi iller ile kesiştiğini sorguladıkselect * from tr_illerwhere st_intersects(geom, st_buffer(st_geomfromtext('POINT(32.9 39.9)',4326),0.5));

--bir noktaya 0.5 derece buffer verip bir tabloya kaydettikselect st_buffer(st_geomfromtext('POINT(32.9 39.9)',4326),0.5) into nokta_buffer;

--Ankara'yı bir çizgi ile ikiye ayırıp geometry collection haline getirdik,--sonra dump ile geometry collectionı iki poligona ayırıp tabloya yazdıkselect (st_dump(st_split(geom,st_geomfromtext('LINESTRING(32.03 40.56,32.94 38.87)',4326)))).geom as geom into ankara_splitfrom tr_iller where iladi='Ankara';

--Ankara ve Kırıkkale illerini birleştirip tek bir obje halinde bir tabloya yazdıkselect 'ankarıkkale'::text as iladi, st_union(geom) as geom into ankarıkkale from tr_iller where iladi in ('Ankara','Kırıkkale');

--Ankara ve Kırıkkale'den oluşan iki poligonu geometrycollection halinde bir araya getirdikselect 'ankarıkkale'::text as iladi, st_collect(geom) as geom into ankarıkkale_collect from tr_iller where iladi in ('Ankara','Kırıkkale');

--ankaranın dışbükey alanlarını bulup tabloya yazdıkselect 'ank_convex'::text as iladi, st_convexhull(geom) as geom into ank_convex from tr_illerwhere iladi='Ankara';

--Ankaranın geometrisini daha az noktadan oluşur halde basitleştirdikselect st_simplify(geom, 0.01) into ank_simple from tr_iller where iladi='Ankara';

--LINEAR REFERENCING

--tanımlanan noktanın iz düşümü tanımlanan çizginin başlangıçtan itibaren hangi yüzdelik kısmına en yakınselect st_linelocatepoint(st_geomfromtext('LINESTRING(1 2, 4 5, 6 7)'), st_geomfromtext('POINT(4 3)'));

--tanımlanan çizginin yüzde 50 lik yani tam orta noktası koordinatları nedirSELECT ST_AsEWKT(ST_LineInterpolatePoint(the_line, 0.5))    FROM (SELECT ST_GeomFromEWKT('LINESTRING(1 2 3, 4 5 6, 6 7 8)') as the_line) As foo;

--geometry gibi geçici bir tablo tanımladım, ilk kolonu çizgi, ikinci kolonu nokta--bu nokta bu çizginin hangi noktasına en yakınwith geometry(line,point) as (SELECT ST_GeomFromText('LINESTRING(1 2, 4 5, 6 7)'),ST_GeomFromText('POINT(4 3)'))select     st_astext(    ST_LineInterpolatePoint(geometry.line, st_linelocatepoint(geometry.line,geometry.point))) from geometry;
