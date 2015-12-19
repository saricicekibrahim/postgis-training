export PATH=/Library/Frameworks/GDAL.framework/Versions/1.11/Programs/:$PATH
ogr2ogr -f "PostgreSQL" PG:"host=localhost user=saricicek dbname=workshop password=" /Users/saricicek/Downloads/osm/shape/roads.shp
ogr2ogr -f "PostgreSQL" PG:"host=localhost user=saricicek dbname=workshop password=" /Users/saricicek/Downloads/osm/shape/points.shp
ogr2ogr -f "PostgreSQL" PG:"host=localhost user=saricicek dbname=workshop password=" /Users/saricicek/Downloads/osm/shape/landuse.shp