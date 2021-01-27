#cd matsim-libs
#git pull origin master
#mvn --also-make package -DskipTests=true
#cd ..
#rm -rf Matsim/matsim-13.0-SNAPSHOT
#mkdir Matsim/matsim-13.0-SNAPSHOT
#cp matsim-libs/matsim/target/matsim-13.0-SNAPSHOT.jar Matsim/matsim-13.0-SNAPSHOT
#cp matsim-libs/contribs/otfvis/target/otfvis-13.0-SNAPSHOT.jar Matsim/matsim-13.0-SNAPSHOT 
# -> this does not work as missing some libraries
# use in otfvis: mvn -Pstandalone --also-make -DskipTests=true package


