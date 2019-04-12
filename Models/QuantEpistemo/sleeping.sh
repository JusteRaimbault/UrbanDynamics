
# db.adminCommand({currentOp: true,"active" : false})["inprog"]

# connections : db.serverStatus().connections

# db.getSiblingDB("admin").aggregate( [    { $currentOp : { allUsers: true, idleSessions: true } },    { $match : { active: true } } ] )

# list sessions
# db.system.sessions.aggregate( [ { $listSessions: { users: [ {user: "myAppReader", db: "test" } ] } } ] ) on db config


