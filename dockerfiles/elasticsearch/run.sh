#!/bin/bash
#
# Set up curator, which will prune or otherwise manage the elastic search
# indexes.
#
rm -f /etc/cron.daily/*
echo "#!/bin/sh" > /etc/cron.daily/es
echo "/usr/local/bin/curator $CURATOR_ARGS" >> /etc/cron.daily/es
chmod +x /etc/cron.daily/es
/etc/init.d/cron start

# Run elasticsearch

/opt/elasticsearch/bin/elasticsearch
