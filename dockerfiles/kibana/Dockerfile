FROM nginx:1
RUN apt-get update && apt-get install -y wget ca-certificates apache2-utils
RUN wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz -O /tmp/kibana.tar.gz && \
    cd /tmp && tar zxf kibana.tar.gz && mv kibana-*/* /usr/share/nginx/html/
RUN mkdir /etc/nginx/ssl
COPY server.key /etc/nginx/ssl/server.key
COPY server.crt /etc/nginx/ssl/server.crt
COPY kibana.conf /etc/nginx/conf.d/kibana.conf
RUN rm -f /etc/nginx/conf.d/default.conf
COPY run.sh /run.sh
RUN chmod +x /run.sh
EXPOSE 80 443
CMD ["/run.sh"]
