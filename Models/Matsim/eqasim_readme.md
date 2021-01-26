
 - run after matsim.simulation.output:

 - Build ile_de_france jar with dependancies in eqasim-java: `mvn -Pstandalone --projects ile_de_france --also-make -DskipTests=true package`
 - run cordon toll test in eqasim-java: `java -Xmx14G -cp ile_de_france/target/ile_de_france-1.2.0.jar org.eqasim.core.scenario.spatial.RunCordonTollSetup`

##

 - run population router (stage in matsim preparation failing with road pricing) within ile_de_france/output with cached repo compiled:
(so that failing java step can be directly run without calling the full prepare subworkflow)

First:

`/usr/bin/java -cp /home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.runtime.eqasim__2cc10c1a980d42d915c99f2e616463c2.cache/eqasim-java/ile_de_france/target/ile_de_france-1.2.0.jar -Xmx14G -Djava.io.tmpdir=/home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.simulation.prepare__c090afb86526969e8097061c99d83739.cache/__java_temp -Dmatsim.useLocalDtds=true org.eqasim.core.scenario.preparation.RunPreparation --input-facilities-path /home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.scenario.facilities__7d101446afa7ebf6f17b9ec0e86e29cf.cache/facilities.xml.gz --output-facilities-path ile_de_france_facilities.xml.gz --input-population-path /home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.scenario.population__f443f4973b054b9ed08d02c82ac8eb19.cache/population.xml.gz --output-population-path prepared_population.xml.gz --input-network-path /home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.scenario.supply.processed__28d114d4a762445bfa3421c342fca51b.cache/network.xml.gz --output-network-path ile_de_france_network.xml.gz --threads 10`

`/usr/bin/java -cp /home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.runtime.eqasim__2cc10c1a980d42d915c99f2e616463c2.cache/eqasim-java/ile_de_france/target/ile_de_france-1.2.0.jar -Xmx14G -Djava.io.tmpdir=/home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.simulation.prepare__c090afb86526969e8097061c99d83739.cache/__java_temp -Dmatsim.useLocalDtds=true org.eqasim.core.scenario.config.RunGenerateConfig --sample-size 0.001 --threads 10 --prefix ile_de_france_ --random-seed 42 --output-path generic_config.xml`

generate departments: synpp in ile_de_france run: matsim.simulation.debug

`/usr/bin/java -cp /home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.runtime.eqasim__2cc10c1a980d42d915c99f2e616463c2.cache/eqasim-java/ile_de_france/target/ile_de_france-1.2.0.jar -Xmx14G -Djava.io.tmpdir=/home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.simulation.prepare__c090afb86526969e8097061c99d83739.cache/__java_temp -Dmatsim.useLocalDtds=true org.eqasim.core.scenario.spatial.RunImputeSpatialAttribute --input-population-path prepared_population.xml.gz --output-population-path prepared_population.xml.gz --input-network-path ile_de_france_network.xml.gz --output-network-path ile_de_france_network.xml.gz --shape-path departments.shp --shape-attribute id --shape-value 75 --attribute isUrban`

`/usr/bin/java -cp /home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.runtime.eqasim__2cc10c1a980d42d915c99f2e616463c2.cache/eqasim-java/ile_de_france/target/ile_de_france-1.2.0.jar -Xmx14G -Djava.io.tmpdir=/home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.simulation.prepare__c090afb86526969e8097061c99d83739.cache/__java_temp -Dmatsim.useLocalDtds=true org.eqasim.core.scenario.spatial.RunAdjustCapacity --input-path ile_de_france_network.xml.gz --output-path ile_de_france_network.xml.gz --shape-path departments.shp --shape-attribute id --shape-value 75 --factor 0.8`

   `/usr/bin/java -cp /home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.runtime.eqasim__2cc10c1a980d42d915c99f2e616463c2.cache/eqasim-java/ile_de_france/target/ile_de_france-1.2.0.jar -Xmx14G -Djava.io.tmpdir=/home/ubuntu/ComplexSystems/UrbanDynamics/Models/Matsim/ile-de-france/cache/matsim.simulation.prepare__c090afb86526969e8097061c99d83739.cache/__java_temp -Dmatsim.useLocalDtds=true org.eqasim.core.scenario.routing.RunPopulationRouting --config-path ile_de_france_config.xml --output-path ile_de_france_population.xml.gz --threads 10 --config:plans.inputPlansFile prepared_population.xml.gz`
-> failing, Null pointer in SwissRaptor: ? - working inside pipeline: missing data files?

   then: ?
