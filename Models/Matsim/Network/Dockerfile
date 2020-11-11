FROM hseeberger/scala-sbt:8u222_1.3.5_2.13.1

RUN git clone https://github.com/openmole/spatialdata.git

RUN mkdir -p /data/outputs

COPY run.sh /root/run.sh

COPY data/OSOpenRoadsTiles.dbf /data/OSOpenRoadsTiles.dbf
COPY data/OSOpenRoadsTiles.prj /data/OSOpenRoadsTiles.prj
COPY data/OSOpenRoadsTiles.qpj /data/OSOpenRoadsTiles.qpj
COPY data/OSOpenRoadsTiles.shp /data/OSOpenRoadsTiles.shp
COPY data/OSOpenRoadsTiles.shx /data/OSOpenRoadsTiles.shx

RUN chmod +x /root/run.sh

RUN cd spatialdata/library;git log|head ;git pull origin master; sbt "project spatialdata" compile

CMD ["/root/run.sh"]

# test docker locally:
#docker run -it --env FUANAME=Exeter -v $CS_HOME/Data/JRC_EC/GHS/GHS_FUA_UCDB2015_GLOBE_R2019A_54009_1K_V1_0:/data/inputs/GHSFUAS -v $CS_HOME/UrbanDynamics/Data/OrdnanceSurvey/OSOpenRoads/:/data/inputs/OSOpenRoads/data matsim-network:1.0
# Q: ivy libs cached, but not compiled classes, why?
