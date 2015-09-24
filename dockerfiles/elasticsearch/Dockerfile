FROM debian:jessie
RUN apt-get update && \
    apt-get install -y openjdk-7-jre wget python-pip cron
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
RUN (cd /tmp && \
    wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.4.tar.gz -O pkg.tar.gz && \
    tar zxf pkg.tar.gz && mv elasticsearch-* /opt/elasticsearch &&\
    rm -rf /tmp/*)
RUN pip install elasticsearch-curator
COPY elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml
COPY run.sh /run.sh
RUN chmod +x /run.sh
EXPOSE 9200
EXPOSE 9300
VOLUME /opt/elasticsearch/data
CMD ["/run.sh"]
