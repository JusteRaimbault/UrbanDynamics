
# build docker images
cd Network
docker build --no-cache -t matsim-network:1.0 .
cd ..

cd Population
docker build --no-cache -t matsim-population:1.0 .
cd ..

cd Matsim
docker build --no-cache -t matsim:1.0 .
cd ..

