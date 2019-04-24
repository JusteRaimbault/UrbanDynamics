PRIORITY=$1

mongo urbmod --quiet --eval "db.references.find({\"citingFilled\":false,\"depth\":{\$gt:0},\"priority\":{\$lt:$PRIORITY}}).count()"

