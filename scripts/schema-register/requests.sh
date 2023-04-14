#!/usr/bin/env bash

# list all subjects from schema registry
curl -X GET http://localhost:8001/api/schema-registry/subjects/

# delete subject, you can see subject namge from Schema Registry UI (http://localhost:8001)
curl -X DELETE http://localhost:8001/subjects/quickstart.sampleData-value?permanent=true
