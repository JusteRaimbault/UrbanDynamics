library(ggplot2)

setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/QuantEpistemo'))

counts <- read.csv('progress.txt',sep=";")
names(counts)<-c("time","refs","links","remaining")

g=ggplot(counts)
g+geom_line(aes(x=time,y=refs))

g=ggplot(counts)
g+geom_point(aes(x=time,y=refs))#+scale_x_date()
