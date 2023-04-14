FROM confluentinc/cp-server-connect-base:7.0.9

#If you want to run a local build of the connector, uncomment the COPY command and make sure the JAR file is in the directory path
#COPY mongo-kafka-connect-<<INSERT BUILD HERE>>3-all.jar /usr/share/confluent-hub-components

RUN confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:1.10.0
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-elasticsearch:11.1.0


ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"
