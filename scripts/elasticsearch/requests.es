GET _cat/indices

GET /quickstart.sampledata/_search
{
  "query": {
    "match_all": {}
  }
}


POST quickstart.sampledata/_doc/
{
  "@timestamp": "2099-11-15T13:12:00",
  "message": "GET /search HTTP/1.1 200 1070000",
  "user": {
    "id": "kimchy",
    "haaaa": "123"
  }
}

// options for dynamic mapping that we can't define schema fit with change payload events
PUT _index_template/template_quickstart
{
  "index_patterns": [
    "quickstart*"
  ],
  "template": {
    "settings": {
      "number_of_shards": 1
    },
    "mappings": {
      "dynamic": true
    }
  }
}

GET /quickstart.sampledata/_mapping
