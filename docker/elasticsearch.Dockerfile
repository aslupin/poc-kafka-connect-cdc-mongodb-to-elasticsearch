FROM docker.elastic.co/elasticsearch/elasticsearch:7.10.2

COPY --chown=elasticsearch:elasticsearch ./conf/elasticsearch.yml /usr/share/elasticsearch/config/
