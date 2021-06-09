#SEED=123
#ITERATIONS=3
echo "Updating configuration file with SEED=$SEED; ITERATIONS=$ITERATIONS; THREADS=$THREADS"

mv /root/config.xml /root/config_tmp.xml

# number of threads both for general and qsim
cat /root/config_tmp.xml | awk '
{if ($0 ~ /randomSeed/) {
  print "		<param name=\"randomSeed\" value=\""'$SEED'"\" />"
  } else {
    if ($0 ~ /lastIteration/) {
        print "		<param name=\"lastIteration\" value=\""'$ITERATIONS'"\" />"
    } else {
      if ($0 ~ /numberOfThreads/) {
          print "		<param name=\"numberOfThreads\" value=\""'$THREADS'"\" />"
      } else {
          print $0
      }
    }
  }
}' > /root/config.xml

# DC mode parameters
#marginalUtilityOfTraveling_util_hr
# $MARGINALUTILITYCAR $MARGINALUTILITYPT $MARGINALUTILITYWALK


rm /root/config_tmp.xml
