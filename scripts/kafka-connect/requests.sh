#!/usr/bin/env bash

# list all connectors
curl -X GET http://connect:8083/connectors

# list connector, tasks, and workers
curl -X GET -s "http://connect:8083/connectors?expand=info&expand=status" | jq '.'

# delete connector
curl -X DELETE http://connect:8083/connectors/mongo-source
curl -X DELETE http://connect:8083/connectors/elasticsearch-sink

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