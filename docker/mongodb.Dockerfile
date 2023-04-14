FROM mongo:3.6.23

# COPY config-replica.js /

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y curl
