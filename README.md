#10 çalışma paketi içeren Postgis Eğitimi
Gerçek anlatımla yaklaşık 2 gün sürer.

#Gereksinimler,
-Postgres 9.x,
-Postgis 2.x

Temelde adres bulma ve konum tabanlı uygulama geliştirmek için faydalıdır.

Data klasörü altında Türkiye iller ve OpenStreetMap'den alınmış Ankara'nın bir bölümünü içeren, arazi kullanımı, bina ve yol datası var.
Bunu pgAdminIII ile veritabanına sağ tuş tıklayıp restore işlemi ile ya da pg_restore.exe ile yükleyebilirsiniz.
Yine data klasöründe osm datasının ham hali ve ogr2ogr ile nasıl yükleneceğini içeren bir sh dosya var.

#workshop1.sql
- veritabanı oluşturma, postgis extension yükleme, st_geomfromtext ile geometrik data girişi, ditance within, ist_ntersects işlemleri içerir

#workshop2.sql
- st_make... ile geometri girişi, projeksiyon dönüşümü, start-end point, geometrik obje nokta sayısı, çizgi başlangıç ya da bitişine tanımlı nokta tanımlı mesafede mi işlemlerini içerir

#workshop3.sql
- operatör kullanımı, noktanın batısındaki il listesi, noktayı mesafe vererek ve projeksiyon dönüşümü ile kaydırma, st_centroid, st_distance, mesafeye göre sıralama işlemleri

#workshop4.sql
- pl/pgsql ile fonksiyon tanımlama, type tanımlama, fonksiyon ile noktaya en yakın yolu bulma işlemleri

#workshop5.sql
- iki farklı yöntemle en yakın yol ve en yakın arazi kullanımını listeleyen fonksiyon

#workshop6.sql
- bir noktaya en yakın yolu ve tanımlı noktaya en yakın noktayı listeleyen sorgu

#workshop7.sql
- id bilgisi verilen iki yolun bboxlarının birbirine değip değmediğini ve bboxları arasındaki uzaklığı veren fonksiyon

#workshop8.sql
- tanımlı nokta ve yol, ilgili uzaklıktaysa yol adı  noktaya uzaklığı veren fonksiyon

#workshop9.sql
- tanımlı noktaya, tanımlanan mesafedeki tüm yol isimleri ve uzaklıklarını listeler

#workshop10.sql
- trigger oluşturma, bir geometri kaydı girerken, başka bir kolona ve tabloya projeksiyonunu değiştirerek aynı kaydı girme işlemleri

Ayrıca sql dosyaları içerisinde detaylı açıklamalara ulaşılabilir...
