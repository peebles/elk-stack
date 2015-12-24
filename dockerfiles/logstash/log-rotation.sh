#!/bin/sh
#
CLOUDFILE="/log/all.log.1"
DT=`date +%s`

mv -f $CLOUDFILE $CLOUDFILE.$DT

# Now we compress and move the old file to S3... do it in the background
# so we don't miss any log data.
/usr/bin/nohup /tmp/s3-upload.sh $CLOUDFILE.$DT  >> /tmp/s3-upload.log &

exit 0
