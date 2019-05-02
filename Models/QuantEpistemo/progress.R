library(ggplot2)
library(lubridate)
library(dplyr)

setwd(paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Models/QuantEpistemo'))

source(paste0(Sys.getenv('CS_HOME'),'/Organisation/Models/Utils/R/plots.R'))

counts <- read.csv('progress.txt',sep=";")
names(counts)<-c("time","refs","links","remaining")
counts$time <- as.POSIXct(counts$time,origin="1970-01-01")

g=ggplot(counts,aes(x=time,y=refs))
g+geom_line()+geom_point(size=0.5)+scale_x_datetime()+ylab('References collected')+stdtheme
ggsave('netstat/refnum_time.png',width=18,height=15,units='cm')


## ip stats

ipcounts <- read.csv('netstat/netstat_20190412_1231.csv')

g=ggplot(ipcounts,aes(x=1:nrow(ipcounts),y=sort(ipcounts$docs,decreasing = T)))
g+geom_point()+scale_x_log10()+scale_y_log10()

# -> should plot rate of success per number of times tried

ips <- as.tbl(read.csv('netstat/netstat_all_20190412_1244.csv'))

rate = ips %>% group_by(ip) %>% summarize(count=n(),successrate=length(which(success=='true'))/length(success))

ipcounts=left_join(ipcounts,rate)
# TODO

