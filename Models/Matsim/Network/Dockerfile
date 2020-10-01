FROM 1science/sbt:0.13-oracle-jdk-8

RUN apk update

RUN apk add git

RUN git clone https://github.com/openmole/spatialdata.git

RUN mkdir /data

COPY run.sh /run.sh

RUN chmod +x /run.sh

RUN cd /app/spatialdata/library; sbt "project spatialdata" compile

CMD ["/run.sh"]
