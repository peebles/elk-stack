#!/bin/sh
# Save AWS creds
echo "export AWS_KEY=\"$AWS_KEY\"" > /tmp/aws.sh
echo "export AWS_SECRET=\"$AWS_SECRET\"" >> /tmp/aws.sh
echo "export S3BUCKET=\"$S3BUCKET\"" >> /tmp/aws.sh
# Start cron for logrotate
/etc/init.d/cron start
# Start logstash
exec /opt/logstash/bin/logstash -f /etc/logstash.conf
