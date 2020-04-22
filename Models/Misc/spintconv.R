

library(sp)


## random

N = 100

coords = matrix(runif(2*N,0,100),ncol = 2)

dij <- spDists(coords)

ai = runif(N,0,1000)
ej = runif(N,0,1000)
kij = matrix(rep(ai,N),nrow=N,byrow = T) +  matrix(rep(ej,N),nrow=N,byrow = F)

f <- function(x){sum(kij*dij*exp(-x*dij))/sum(kij*exp(-x*dij))}

dx = 0.01

plot(sapply(seq(0,100,dx),f),type='l')

fp = diff(sapply(seq(0,100,dx),f))/0.01
max(abs(fp))

l = 10
g<- function(x){abs(f(x)-l)}
xstar = optimize(g,c(0,2))$minimum

dx = 0.0001
1 - xstar*((f(xstar+dx) - f(xstar))/dx)/l


####
# real data

library(Matrix)

dij = read.csv(file = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/QUANT/converted/dis_roads_min.csv'),header=F,skip = 1)
dij=Matrix(as.matrix(dij))

Tijsparse = read.csv(file = paste0(Sys.getenv('CS_HOME'),'/UrbanDynamics/Data/QUANT/converted/TObs_1.csv'),header=F,skip = 1)
Tij = sparseMatrix(i=Tijsparse$V1,j=Tijsparse$V2,x=Tijsparse$V3,dims=dim(dij),index1 = F)

dbar = sum(dij*Tij)/sum(Tij) 

kij = Matrix(matrix(rep(rowSums(Tij),nrow(Tij)),nrow = nrow(Tij),byrow = T) + matrix(rep(colSums(Tij),nrow(Tij)),nrow = nrow(Tij),byrow = F))

f <- function(x){sum(kij*dij*exp(-x*dij))/sum(kij*exp(-x*dij))}

g <- function(x){x*f(x)/dbar}

xstar=1
for(k in 1:10){
  xstar = g(xstar)
  show(xstar)
}

dx = 0.0001
gp <- function(x){(g(x+dx)-g(x))/dx}

gp(xstar)
gp(1)
gp(0)
gp(g(1))

xvals = seq(0.025,0.035,0.001)
plot(xvals,sapply(xvals,g),type='l');points(xvals,xvals,col='red',type='l',add=T)






