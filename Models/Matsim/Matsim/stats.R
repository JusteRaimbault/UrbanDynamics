
setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/Matsim/'))

#library(dplyr)
#library(ggplot2)
library(sf)



#source(paste0(Sys.getenv('CS_HOME'),'/Organisation/Models/Utils/R/plots.R'))
system('gzip -d test/outputs/output_trips.csv.gz')

trips <- read.csv('test/outputs/output_trips.csv',sep=';')

start = st_as_sf(trips[,c("start_x","start_y")],coords = 1:2)
st_crs(start)<-4326
end = st_as_sf(trips[,c("end_x","end_y")],coords = 1:2)
st_crs(end)<-4326

distances = as.numeric(st_distance(start,end, by_element = T))
summary(distances)

#times <- sapply(strsplit(as.character( trips$trav_time),":"),function(t){as.numeric(t[2])+as.numeric(t[1])*60})
times <- sapply(strsplit(as.character( trips$trav_time),":"),function(t){as.numeric(t[3])+as.numeric(t[2])*60+as.numeric(t[1])*3600})


# times may be in minutes? NO! same time format
#summary(times/60)
summary(times/3600)

# speed in km/h: very low values: ?
speeds = distances / 1000 / (times/3600)
summary(speeds)
#summary(speeds[speeds<150])

