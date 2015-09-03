#!/bin/bash

KIBANA_USER=${KIBANA_USER-admin}
KIBANA_PASS=${KIBANA_PASS-password}

htpasswd -b -c /etc/nginx/conf.d/kibana.htpasswd $KIBANA_USER $KIBANA_PASS

nginx

cd /deploy/kibana
./bin/kibana

