#!/bin/bash

KIBANA_USER=${KIBANA_USER-admin}
KIBANA_PASS=${KIBANA_PASS-password}

htpasswd -b -c /etc/nginx/conf.d/kibana.htpasswd $KIBANA_USER $KIBANA_PASS
sed -i 's/9200/443/g' /usr/share/nginx/html/config.js
sed -i 's/http:/https:/g' /usr/share/nginx/html/config.js

nginx -g "daemon off;"
