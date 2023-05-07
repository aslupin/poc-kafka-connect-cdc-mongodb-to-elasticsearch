// step 1) shell to your mongo container with `docker exec -it mongo1 /bin/bash`  command

// step 2) run one of these command for connecting replica `rs0`
// `mongo mongodb://mongo1:27017/?replicaSet=rs0` for MongoDB version 3.X
// `mongosh mongodb://mongo1:27017/?replicaSet=rs0` for MongoDB version 6.X


// step 3) run `use quickstart` command for switching to quickstart db

// step 4) create `sampleData` collection
db.createCollection('sampleData')

// step 5) try to insert document and monitor on the topic
db.sampleData.insertOne({ "hello": "world"})

// step 6) try to change document value
db.sampleData.updateOne(
  { _id: ObjectId("your-document-object-id") },
  { $set: { hello: "updated"} },
)

// more information about change events
// https://www.mongodb.com/docs/manual/reference/change-events/
