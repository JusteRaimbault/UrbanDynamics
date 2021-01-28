FROM hseeberger/scala-sbt:8u222_1.3.5_2.13.1

RUN git clone https://github.com/openmole/spatialdata.git

RUN mkdir -p /data/outputs

COPY run.sh /root/run.sh

COPY map_network.ipynb /root/map_network.ipynb

RUN chmod +x /root/run.sh

RUN cd spatialdata/library;git log|head ;git pull origin master
#; sbt "project spatialdata" compile

CMD ["/root/run.sh"]
