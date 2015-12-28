--trigger işlemi yapacağız
--spatialdata tablosuna bir geometri girerken
--bu değerin projeksiyonunu değiştirsin
--ve başka bir kolona ve başka bir tabloya yazsın

--yeni kolon oluşturuyoruz
alter table spatialdata 
add column geom_900913 geometry;

--yeni tablo oluşturuyoruz
CREATE TABLE spatialdata2
(id serial,
geom geometry);

--trigger işleminde çalışacak fonksiyonu tanımlıyoruz
CREATE OR REPLACE FUNCTION update_projection()
  RETURNS trigger AS
$BODY$
BEGIN
 NEW.geom_900913 = st_transform(NEW.geom,900913);
 insert into spatialdata2(geom) select NEW.geom_900913;
 RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE STRICT;

--tablo üzerine trigger tanımlıyoruz
CREATE TRIGGER update_projection_trg before INSERT OR UPDATE
ON spatialdata
FOR EACH ROW
EXECUTE PROCEDURE update_projection();


--bir kayıt girişi yapıyoruz
insert into spatialdata (geom) select st_geomfromtext('POINT(35 39)',4326);

--ilgili kolon doldu mu diye kontrol ediyoruz
select * from spatialdata where geom_900913 is not null

--ilgili tabloya kayıt girdi mi diye kontrol ediyoruz
select * from spatialdata2;