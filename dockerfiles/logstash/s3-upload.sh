#!/bin/sh
#
# Compress a logfile and upload it to s3.
#
# REQUIRES THESE ENV VARS:
#
# AWS_KEY
# AWS_SECRET
# S3BUCKET ( ex. s3://mycloudlogs )

LOGFILE="$1"
LOGDIR=`dirname $LOGFILE`
LOGBN=`basename $LOGFILE`

. /tmp/aws.sh

# Compress the file first
( cd $LOGDIR; gzip $LOGFILE )

# Upload it to s3
cmd="/usr/bin/s3cmd --access_key $AWS_KEY --secret_key $AWS_SECRET put $LOGFILE.gz $S3BUCKET/$LOGBN.gz"
$cmd

# and remove it
rm -f $LOGFILE.gz
