# Stream data from MongoDB to Elasticsearch by using Kafka Connect
A repository PoC streaming data from MongoDB as upstream to Elasticsearch downstream by using Kafka Connect and additional tools for monitoring. inspired by https://github.com/mongodb-university/kafka-edu repository

# Prerequisites 🚀
- [Docker](https://docs.docker.com/get-docker/)

# mongodb-source-to-elasticsearch-sink using JsonSchemaConverter
An environment will PoC about to capture data changes from MongoDB to Elasticsearch use case

`docker-compose` will contains these services
- Apache Kafka
- Zookeeper
- Apache Kafka Connect
- Confluent REST Proxy for Kafka
- Confluent Schema Registry
- MongoDB Connector 
- Elasticsearch Connector Sink
- MongoDB single node replica set
- Kibana
- Elasticsearch
- Redpanda Console (integrated with Schema Registry and Kafka Connect)

### Start Development 🚧
step 1) you have to change directories and start all services by using
```sh
cd playgrounds/mongodb-source-to-elasticsearch-sink
make up
```

step 2) shell to some container (we will use `mongo1`)
```sh
make exe
```

step 3) we have to create collection first for initialing cursor that source connector use it to capture changes and produce it to kafka topic

3.1) shell to MongoDB replica
```sh
mongo mongodb://mongo1:27017/?replicaSet=rs0    # for MongoDB version 3.X
mongosh mongodb://mongo1:27017/?replicaSet=rs0  # for MongoDB version 6.X
```

3.2) switch to target database
```sh
use quickstart
```

3.3) create a collection
```js
db.createCollection('sampleData')
```

step 4) add source and sink connector, these command will add `mongo-source` as source connector and `elasticsearch-sink` as sink connector to capture data changes from upstream data to Kafka topic then push it to downstream. for more commands, you can see at `scripts/kafka-connect/requests.sh`

(optional) you can do this step by using Redpanda Console to create/edit/delete connectors on this [http://localhost:8888/connect-clusters/connect-local](http://localhost:8888/connect-clusters/connect-local)


4.1) shell and open new session for commanding connector
```sh
make exe
```

4.2) add connectors
```sh
# add new mongo-source connector as a source connector by using JsonSchemaConverter
curl -X POST \
  -H "Content-Type: application/json" \
  --data '
  {
    "name": "mongo-source",
    "config": {
      "connector.class": "com.mongodb.kafka.connect.MongoSourceConnector",
      "connection.uri": "mongodb://mongo1:27017/?replicaSet=rs0",
      "database": "quickstart",
      "collection": "sampleData",
      "pipeline": "[{\"$match\": {\"operationType\": \"insert\"}}, {$addFields : {\"fullDocument.travel\":\"MongoDB Kafka Connector\"}}]",

      "output.json.formatter": "com.mongodb.kafka.connect.source.json.formatter.SimplifiedJson",
      "output.format.value": "schema",
      "output.format.key": "json",

      "value.converter":"io.confluent.connect.json.JsonSchemaConverter",
      "value.converter.schema.registry.url": "http://schema-registry:8081",
      "key.converter": "org.apache.kafka.connect.storage.StringConverter",

      "output.schema.infer.value" : true,
      "publish.full.document.only": true,

      "transforms": "createKey,extractString",
      "transforms.createKey.type": "org.apache.kafka.connect.transforms.ValueToKey",
      "transforms.createKey.fields": "hello",
      "transforms.extractString.type": "org.apache.kafka.connect.transforms.ExtractField$Key",
      "transforms.extractString.field": "hello"
    }
  }
  ' \
  http://connect:8083/connectors -w "\n"

# add new elasticsearch-sink connector as a sink connector by using JsonSchemaConverter
curl -X POST \
  -H "Content-Type: application/json" \
  --data '
	{
    "name": "elasticsearch-sink",
    "config": {
      "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
      "connection.url": "http://elasticsearch:9200",
      "topics": "quickstart.sampleData",
      "tasks.max": "1",

      "value.converter":"io.confluent.connect.json.JsonSchemaConverter",
      "value.converter.schema.registry.url": "http://schema-registry:8081",
      "key.converter": "org.apache.kafka.connect.storage.StringConverter",

      "transforms": "createKey,extractString,ReplaceField",
      "transforms.createKey.type": "org.apache.kafka.connect.transforms.ValueToKey",
      "transforms.createKey.fields": "_id",
      "transforms.extractString.type": "org.apache.kafka.connect.transforms.ExtractField$Key",
      "transforms.extractString.field": "_id",
      "transforms.ReplaceField.type": "org.apache.kafka.connect.transforms.ReplaceField$Value",
      "transforms.ReplaceField.exclude": "_id"
    }
	}
	' \
  http://connect:8083/connectors -w "\n"
```

step 5) we will try to trigger or make some change events to out upstream system by insert one document to collection. for more commands, you can see at `scripts/mongodb/manual.js`

5.1) insert or update document that make event changes. you can read other events from this [Change Events - MongoDB](https://www.mongodb.com/docs/manual/reference/change-events/)
```js
db.sampleData.insertOne({ "hello": "world"})


db.sampleData.updateOne(
  { _id: ObjectId("your-document-object-id") },
  { $set: { hello: "updated"} },
)
```

5.2) you can monitoring data flow from these URL
- [http://localhost:8888](http://localhost:8888) Redpanda
  - [http://localhost:8888/connect-clusters/connect-local](http://localhost:8888/connect-clusters/connect-local) manage Kafka connectors on UI
  - [http://localhost:8888/schema-registry](http://localhost:8888/schema-registry) manage Schema Registry that used from both source and sink connector
  - [http://localhost:8888/topics](http://localhost:8888/topics) manage message several topics that storing data from upstream
- [http://localhost:8001](http://localhost:8001) alternative UI for managing schema registry
- [http://127.0.0.1:5602/app/dev_tools#/console](http://127.0.0.1:5602/app/dev_tools#/console) Kibana Dev Tool for requesting command to Elasticsearch. for more requests, you can see at `scripts/elasticsearch/requests.es` ([ES extension - VS code extension](https://marketplace.visualstudio.com/items?itemName=ria.elastic))

## References 🙏
- [Kafka EDU - Mongodb University Org](https://github.com/mongodb-university/kafka-edu)
- [Kafka Connect 101](https://developer.confluent.io/learn-kafka/kafka-connect/intro)
- [Confluent REST Proxy for Kafka](https://github.com/confluentinc/kafka-rest)
- [Schema Registry](https://docs.confluent.io/platform/current/schema-registry/index.html)
- [Schema Registry UI](https://hub.docker.com/r/landoop/schema-registry-ui/)
- [Redpanda + Schema Registry](https://docs.redpanda.com/docs/manage/schema-registry/)
- [Redpanda Console](https://docs.redpanda.com/docs/manage/console/kafka-connect/)
- [MongoDB Kafka Connector](https://docs.mongodb.com/kafka-connector/current/)
- [Connectors to Kafka](https://docs.confluent.io/home/connect/overview.html)
- [Change Events - MongoDB](https://www.mongodb.com/docs/manual/reference/change-events/)
- [MongoDB connector for Kafka 1.3](https://www.mongodb.com/blog/post/mongo-db-connector-for-apache-kafka-1-3-available-now)
- [Single Message Transforms for Confluent Platform](https://docs.confluent.io/platform/current/connect/transforms/overview.html)
- [Debezium MongoDB Source Connector for Confluent Platform](https://docs.confluent.io/kafka-connectors/debezium-mongodb-source/current/overview.html#debezium-mongodb-source-connector-for-cp)
