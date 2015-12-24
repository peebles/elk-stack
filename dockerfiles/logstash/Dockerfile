FROM debian:jessie
RUN apt-get update && \
    apt-get install -y wget nano logrotate s3cmd openjdk-7-jre less
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV TERM xterm
RUN wget https://download.elastic.co/logstash/logstash/packages/debian/logstash_1.5.4-1_all.deb -O /tmp/logstash.deb && \
    dpkg -i /tmp/logstash.deb ; \
    apt-get -f -y install && \
    rm -rf /tmp/logstash.deb
RUN cd /opt/logstash && bin/plugin install logstash-filter-json_encode
COPY log-rotation.sh /tmp/log-rotation.sh
COPY s3-upload.sh /tmp/s3-upload.sh
RUN chmod +x /tmp/log-rotation.sh /tmp/s3-upload.sh
COPY logstash.conf /etc/logstash.conf
# We will want to rotate at 200M bounderies which could happen
# at any time.
COPY logrotate.conf /etc/logrotate.d/logs
# Run our startup commands( cron, logstash )
COPY run.sh /tmp/run.sh
RUN mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate
RUN rm -f /etc/cron.daily/*
# For logrotate
RUN /etc/init.d/cron start
# To store application logs
VOLUME ["/log"]
EXPOSE 5000 5001 5000/udp 5001/udp
RUN mkdir -p /log
# For ease of running tail -f, ls -ltr, etc
WORKDIR /log
CMD sh /tmp/run.sh
