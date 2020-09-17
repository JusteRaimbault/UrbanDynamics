FROM openmole/openmole:latest

COPY Script.oms /Script.oms

CMD ["openmole", "--script","/Script.oms","--password","oml"]

# note: must run once, set password by hand, and commit to container
# ! run with hostname, otherwise pref saved in different directories each time (host by default from docker is a hash)
# and sh command
# commit with --change='CMD ["openmole", "--script","/Script.oms","--password","oml"]' to reset the run command
