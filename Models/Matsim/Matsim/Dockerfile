FROM openjdk:11.0.9-jre

COPY run.sh /root/run.sh

COPY matsim-13.0 /root/matsim-13.0

COPY config.xml /root/config.xml

COPY config.sh /root/config.sh

RUN chmod +x /root/config.sh

RUN chmod +x /root/run.sh

RUN mkdir /data

CMD ["/root/run.sh"]
