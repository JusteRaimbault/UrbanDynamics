#!/bin/sh

if [ -z "$MEMORY" ]
then
    export MEMORY=18G
fi

if [ -z "$PARALLEL" ]
then
    export PARALLEL="false"
fi

cd spatialdata/library
export SBT_OPTS="-Xmx$MEMORY"
mkdir -p /data/outputs

if [ "$PARALLEL" = "true" ] ; then
    for NAME in ${FUANAME//;/ } ; do
        echo "run $NAME"
        sbt "project spatialdata; runMain org.openmole.spatialdata.application.matsim.RunMatsim --network --FUAName=\""$NAME"\" --FUAFile=/data/inputs/GHSFUAS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0_WGS84.gpkg --TilesFile=/data/inputs/OSOpenRoadsTiles/OSOpenRoadsTiles.shp --datadir=/data/inputs/OSOpenRoads/data --output=/data/outputs/Network;" &
        R -e 'source("functions.R"); extract_gtfs($NAME,/data/inputs/GHSFUAS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0_WGS84.gpkg)'
    done
else
    sbt "project spatialdata; runMain org.openmole.spatialdata.application.matsim.RunMatsim --network --FUAName=\""$FUANAME"\" --FUAFile=/data/inputs/GHSFUAS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0_WGS84.gpkg --TilesFile=/data/inputs/OSOpenRoadsTiles/OSOpenRoadsTiles.shp --datadir=/data/inputs/OSOpenRoads/data --output=/data/outputs/Network;"
    R -e 'source("functions.R"); extract_gtfs($FUANAME,/data/inputs/GHSFUAS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0_WGS84.gpkg)'
fi

cp /root/map_network.ipynb /data/outputs/map_network.ipynb


: '
# test docker locally
docker build --no-cache -t matsim-network:1.0 .
docker run -it --env FUANAME="Taunton" \
-v $CS_HOME/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0:/data/inputs/GHSFUAS \
-v $CS_HOME/UrbanDynamics/Models/Matsim/Network/data:/data/inputs/OSOpenRoadsTiles \
-v $CS_HOME/UrbanDynamics/Data/OrdnanceSurvey/OSOpenRoads:/data/inputs/OSOpenRoads/data \
matsim-network:1.0
'
#  --env PARALLEL=true
# Taunton;Weston-super-Mare
# "Taunton,Weston-super-Mare;Exeter,Torquay"
# Q: ivy libs cached, but not compiled classes, why?

: '
# build and save docker image
docker build --no-cache -t matsim-network:1.0 .
cd ..
docker save matsim-network:1.0 | gzip > images/matsim-network-1.0-`git rev-parse --short=10 HEAD`.tar.gz
'
