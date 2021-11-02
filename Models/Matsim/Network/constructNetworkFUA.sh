#!/bin/sh

# script to preprocess networks locally (not in docker)

FUANAME=$1

# parameters
FUAFILE=$CS_HOME/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0_WGS84.gpkg
GTFSDIR=$CS_HOME/UrbanDynamics/Data/TNDS/gtfs_20210322
#OSMFILE=$CS_HOME/Data/OSM/Geofabrik/luxembourg/luxembourg-latest_20211030.osm.pbf # for testing
OSMFILE=$CS_HOME/Data/OSM/Geofabrik/britain-and-ireland/britain-and-ireland-latest_20211102.osm.pbf

# get poly file from fuafile
#R -e 'source("functions.R"); create_poly_file("'$FUAFILE'","'$FUANAME'")'

# extract data with osmosis
#osmosis --read-pbf $OSMFILE --tag-filter accept-ways highway=* railway=* --bounding-polygon file=runtime/$FUANAME.poly completeWays=yes --write-xml compressionMethod=gzip  runtime/$FUANAME.osm.gz

# extract gtfs
#R -e 'source("functions.R"); extract_gtfs("'$FUAFILE'","'$GTFSDIR'","'$FUANAME'")'

# default config
java -Xmx4G -Dmatsim.useLocalDtds=true -cp pt2matsim-21.5/pt2matsim-21.5-shaded.jar org.matsim.pt2matsim.run.CreateDefaultOsmConfig runtime/defaultConfigFile.xml
while IFS= read -r confline; do
  if [[ $confline =~ "osmFile" ]]; then
     echo '<param name="osmFile" value="runtime/'$FUANAME'.osm.gz" />' >> runtime/config.xml
  else
     if [[ $confline =~ "outputCoordinateSystem" ]]; then
         echo '<param name="outputCoordinateSystem" value="EPSG:4326" />' >> runtime/config.xml
     else
       if [[ $confline =~ "outputNetworkFile" ]]; then
           echo '<param name="outputNetworkFile" value="runtime/network.xml.gz" />' >> runtime/config.xml
       else
         if [[ $confline =~ "</module>" ]]; then
             echo '<parameterset type="routableSubnetwork"><param name="allowedTransportModes" value="car" /><param name="subnetworkMode" value="car_passenger" /></parameterset></module>' >> runtime/config.xml
         else
             echo "$confline" >> runtime/config.xml
         fi
       fi
     fi
  fi
done <runtime/defaultConfigFile.xml


# construct multimodalnetwork
java -Xmx20G -Dmatsim.useLocalDtds=true -cp pt2matsim-21.5/pt2matsim-21.5-shaded.jar org.matsim.pt2matsim.run.Gtfs2TransitSchedule runtime/config.xml

# gtfs to transit schedule
