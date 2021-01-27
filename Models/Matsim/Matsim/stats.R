
setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/Matsim/Matsim'))

#library(dplyr)
#library(ggplot2)
library(sf)



#source(paste0(Sys.getenv('CS_HOME'),'/Organisation/Models/Utils/R/plots.R'))

trips <- read.csv('outputs/output/output_trips.csv',sep=';')

start = st_as_sf(trips[,c("start_x","start_y")],coords = 1:2)
st_crs(start)<-4326
end = st_as_sf(trips[,c("end_x","end_y")],coords = 1:2)
st_crs(end)<-4326

st_distance(start,end, by_element = T)
