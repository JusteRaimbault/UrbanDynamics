
setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/Matsim/'))

#library(dplyr)
library(ggplot2)
library(lubridate)
library(sf)
library(digest)

source(paste0(Sys.getenv('CS_HOME'),'/Organisation/Models/Utils/R/plots.R'))

resdir = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Results/Matsim/Sensitivity');dir.create(resdir,recursive = T)

####
# Tests


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


#####
# Functions



getTrips <- function(resdirs){
  trips=data.frame()
  for(r in resdirs){
    system(paste0('gzip -d simulations/',r,'/output_trips.csv.gz'))
    currenttrips <- read.csv(paste0('simulations/',r,'/output_trips.csv'),sep=';')
    resdirsplit = strsplit(r,"_")
    fuaname = strsplit(resdirsplit[[1]][2],"-")[[1]][2]
    seed=paste0(strsplit(resdirsplit[[1]][length(resdirsplit[[1]])-2],"-")[[1]][2],resdirsplit[[1]][length(resdirsplit[[1]])])
    
    start = st_as_sf(currenttrips[,c("start_x","start_y")],coords = 1:2);st_crs(start)<-4326
    end = st_as_sf(currenttrips[,c("end_x","end_y")],coords = 1:2);st_crs(end)<-4326
    distances = as.numeric(st_distance(start,end, by_element = T))
    
    trips = rbind(trips,cbind(currenttrips,origseed=rep(seed,nrow(currenttrips)),fua=rep(fuaname,nrow(currenttrips)),distances=distances))
  }
  
  trips$duration = sapply(strsplit(as.character(trips$trav_time),":"),function(t){as.numeric(t[3])+as.numeric(t[2])*60+as.numeric(t[1])*3600})
  trips$start = sapply(strsplit(as.character(trips$dep_time),":"),function(t){as.numeric(t[3])+as.numeric(t[2])*60+as.numeric(t[1])*3600})
  trips$start_time = parse_date_time(seconds_to_period(trips$start),"%H %M %S")
  trips$seed = as.numeric(sapply(as.character(trips$origseed),function(s){strtoi(substring(digest(s, algo='xxhash32'),1,3),16)}))
  return(trips)
}


  


####
# Stochasticity


targetfua = "Taunton"
# ! needs fixed sampling 0.1: ok
trips = getTrips(list.files('simulations/')[list.files('simulations/') %>% grep(pattern = targetfua)])


#g=ggplot(trips,aes(x=start_time))
#g+geom_density()

g=ggplot(trips,aes(x=start,group=seed,color=as.character(seed)))
g+geom_density()+scale_color_discrete(name="Random seed")+
  ylab("Density")+xlab("Trip departure time")+ggtitle(paste0("FUA: ",targetfua))+stdtheme
ggsave(file=paste0(resdir,'/stochasticity_',targetfua,'.png'),width=20,height=15,units='cm')

####
# Compare accross areas

ignoredfua = "Taunton"
trips = getTrips(list.files('simulations/')[list.files('simulations/') %>% grep(pattern = ignoredfua,invert = T)])

g=ggplot(trips,aes(x=start,group=fua,color=fua))
g+geom_density()+scale_color_discrete(name="Urban area")+
  ylab("Density")+xlab("Trip departure time")+stdtheme
ggsave(file=paste0(resdir,'/departuretimes_allFUAs.png'),width=20,height=15,units='cm')


g=ggplot(trips[trips$distances<50000,],aes(x=distances/1000,group=fua,color=fua))
g+geom_density()+scale_color_discrete(name="Urban area")+
  ylab("Density")+xlab("Trip distance")+stdtheme
ggsave(file=paste0(resdir,'/distances_allFUAs.png'),width=20,height=15,units='cm')





