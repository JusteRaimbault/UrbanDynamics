

FUAFILE=$CS_HOME/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0_WGS84.gpkg

R -e 'source("functions.R"); create_all_poly_files("'$FUAFILE'","GBR")'

rm extractFUAsOSM.sh
echo "# extract OSM files for each FUA" >> extractFUAsOSM.sh
echo 'OSMFILE=$CS_HOME/Data/OSM/Geofabrik/britain-and-ireland/britain-and-ireland-latest_20211102.osm.pbf' >> extractFUAsOSM.sh

i=0
for poly in "runtime"/*.poly
do
  if (( $i % 10 == 0 ))
  then
     echo "" >> extractFUAsOSM.sh
     echo "" >> extractFUAsOSM.sh
     echo -n 'osmosis --read-pbf $OSMFILE --tee 10 ' >> extractFUAsOSM.sh
  fi
  fuapref="$( cut -d '.' -f 1 <<< "$poly" )"
  fua="$( cut -d '/' -f 2 <<< "$fuapref" )"
  echo $fua
  #if [[ $fua == "LAD_E"* ]]
  #then
    echo -n "--tag-filter accept-ways highway=* railway=* --bounding-polygon file=runtime/$fua.poly completeWays=yes --write-xml compressionMethod=gzip runtime/"$fua".osm.gz " >> extractFUAsOSM.sh
    i=$(($i + 1))
  #fi
done


chmod u+x extractFUAsOSM.sh
