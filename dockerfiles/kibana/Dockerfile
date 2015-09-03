FROM nginx:1
RUN apt-get update && apt-get install -y wget ca-certificates apache2-utils
RUN wget https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz -O /tmp/kibana.tar.gz && \
    mkdir -p /deploy/kibana && cd /tmp && tar xf kibana.tar.gz -C /deploy/kibana --strip-components=1
COPY kibana.yml /deploy/kibana/config/kibana.yml
RUN mkdir /etc/nginx/ssl
COPY server.key /etc/nginx/ssl/server.key
COPY server.crt /etc/nginx/ssl/server.crt
COPY kibana.conf /etc/nginx/conf.d/kibana.conf
RUN rm -f /etc/nginx/conf.d/default.conf
COPY run.sh /run.sh
RUN chmod +x /run.sh
EXPOSE 80 443
CMD ["/run.sh"]
