FROM openmole/openmole:latest

COPY Script.oms /Script.oms

COPY run.sh /run.sh

RUN chmod +x /run.sh

RUN mkdir -p /data/outputs

CMD ["/run.sh"]

# note: must run once, set password by hand, and commit to container?
# ! NO -> either do this with --workspace option
# or provide dummy password as stdin in run script
