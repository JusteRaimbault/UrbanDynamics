cd /home/ubuntu/ComplexSystems/UrbanDynamics/Models/QuantEpistemo

TOTAL=`mongo urbmod --quiet --eval "db.references.count()"`
LINKS=`mongo urbmod --quiet --eval "db.links.count()"`
REMAINING=`mongo urbmod --quiet --eval 'db.references.find({"citingFilled":false,"depth":{$gt:0}}).count()'`
DATE=`date +%s`

echo "$TOTAL;$LINKS;$REMAINING"

echo "$DATE;$TOTAL;$LINKS;$REMAINING" >> progress.txt
