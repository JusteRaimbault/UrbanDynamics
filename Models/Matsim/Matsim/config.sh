#SEED=123
#ITERATIONS=3

#cd /root
#rm config2.xml

echo "Updating configuration file with SEED=$SEED; ITERATIONS=$ITERATIONS; THREADS=$THREADS; UTILITYWALK=$UTILITYWALK; UTILITYPT=$UTILITYPT; UTILITYCAR=$UTILITYCAR"

#mv config.xml config_tmp.xml
rm config_runtime.xml

# number of threads both for general and qsim
cat config.xml | awk '
{if ($0 ~ /randomSeed/) {
  print "		<param name=\"randomSeed\" value=\""'$SEED'"\" />"
  } else {
    if ($0 ~ /lastIteration/) {
        print "		<param name=\"lastIteration\" value=\""'$ITERATIONS'"\" />"
    } else {
      if ($0 ~ /numberOfThreads/) {
          print "		<param name=\"numberOfThreads\" value=\""'$THREADS'"\" />"
      } else {
        if ($0 ~ /param name=\"mode\" value=\"walk\"/) {
            print "		<param name=\"mode\" value=\"walk\" /><param name=\"dailyUtilityConstant\" value=\""'$UTILITYWALK'"\" />"
        } else {
          if ($0 ~ /param name=\"mode\" value=\"pt\"/) {
              print "		<param name=\"mode\" value=\"pt\" /><param name=\"dailyUtilityConstant\" value=\""'$UTILITYPT'"\" />"
          } else {
            if ($0 ~ /param name=\"mode\" value=\"car\"/) {
                print "		<param name=\"mode\" value=\"car\" /><param name=\"dailyUtilityConstant\" value=\""'$UTILITYCAR'"\" />"
            } else {
                print $0
            }
          }
        }
      }
    }
  }
}' > config_runtime.xml

# DC mode parameters
#marginalUtilityOfTraveling_util_hr
# $MARGINALUTILITYCAR $MARGINALUTILITYPT $MARGINALUTILITYWALK
# -> will depend on travel time for each mode -> better use utility constants
# <param name="mode" value="walk" /><param name="dailyUtilityConstant" value="0.0" />

#rm config_tmp.xml
