# ElasticSearch/Kibana/Logstash (ELK) Stack

This is a "docker-compose" stack that runs a simple setup with one Elastic Search instance, a Logstash instance
and a Kibana instance.  You must do a little bit of preperation first before deploying this stack, to meet your
requirements.

This stack is designed to be relatively secure.  Access to Kibana is done over HTTPS and the Elasic Search service
can be secured behind a security group (or otherwise made accessible only to the Kibana instance and the Logstash
instance.  Access to the Logstash instance can be protected or be open to the internet depending on how your
applications need to log to it.

There is an application called the "proxy" that sits in front of logstash.  This proxy provides a "tail -f"
web gui on incoming messages, and has an interface for specifying regular expressions that identify "events"
which can be sent via email to interested parties.  This is on port 8080.

## AWS EC2

You can create a machine to host this stack by executing:

    docker-machine create --driver amazonec2 \
               --amazonec2-access-key YOUR_AWS_KEY \
               --amazonec2-secret-key YOUR_AWS_SECRET \
	       --amazonec2-vpc-id YOUR_VPC_ID \
               --amazonec2-region YOUR_AWS_REGION \
               --amazonec2-zone YOUR_AWS_ZONE \
               --amazonec2-security-group sgelk \
               --amazonec2-instance-type t2.small \
	       elk

Once this is up, go to the aws console and edit the "sgelk" security group.  Add global access to ports 80, 8080
and 443.  Add access to port 9200 to THIS SECURITY GROUP ONLY.  Add access to UDP port 3030 and TCP port 3030
to everyone, or to a security group, depending on how you are logging (port 3030 is the Logstash port).  Also
add access to 3031 udp/tcp if you want to use "meta logging".

Kibana will be on port 80 (or 443).  The logstash proxy web gui will be on port 8080.

### Meta Logging

The logstash.config in this stack listens on 5000 udp/tcp and tags any incoming messages with type=syslog.
It also listens on 5001 udp/tcp and tags any messages coming in on those ports with type=meta.  You can
take advantage of this by sending normal log messages to 5000 and any special messages to 5001.  You can
then filter for "type:syslog" in Kibana to see only the normal log messages, and "type:meta" to see
special messages.  I use this technique to write data structures into elastic search for analytics.

## Protect Kibana

Read the readme.md in dockerfiles/kibana.  That will tell you how to create HTTPS keys
for access to Kibana.  Follow those directions.  You will be adding a server.key and server.crt to that directory.

## Configure Logstash

The default logstash config file is dockerfiles/logstash/logstash.conf.  This is set up to accept pure JSON
objects (as strings) on port 5000 (mapped to 3030 by docker) for both TCP and UDP.  The pure JSON objects
should contain at least:

    {
        "level": "info", (or debug, warn, error, etc)
        "message": "the message",
        "program": "the name of the program that generated this message",
        "meta": { any meta data }
    }

and can contain anything else you want.

The default config is good if you want the most flexible dataset to query in Kibana/Elastic Search.  But you
can copy logstash.RFC3164.conf to logstash.conf if your scripts will be using standard syslog for logging.

In all cases, log messages will be sent to Elastic Search.  In addition, they are written as human readable
ASCII files in the logstash container.  All messages are concat'd to a file called "all.log" and messages
from each individual "program" are also written to "program".log.  These log files are log-rotated at 200Mb
bounderies and gzip'd and copied to S3 for long term storage.  The rotated log files are then removed from
the container.  You can access a log file like this:

    docker exec -it elk_logs_1 tail -f "program".log

or

    docker exec -it elk_logs_1 tail -f all.log


## Edit your Environment

Copy docker-compose-common.yml.sample to docker-compose-common.yml.  Change the YOUR_AWS_KEY and YOUR_AWS_SECRET to your values.
Change YOUR_S3_BUCKET to a S3 bucket of your choosing for storing rotated log files.  Change KIBANA_USER and KIBANA_PASS to
a username/password for access to the Kibana web pages.

For the proxy service which sends email, there are more enviornment variables that must be set:

    PROXY_SQLITEDB:       /data/logger.db
    PROXY_WEBSERVER_USER: admin
    PROXY_WEBSERVER_PASS: password
    PROXY_SMTP_USER:      smpt-server-username
    PROXY_SMTP_PASS:      smtp-server-password
    PROXY_SMTP_HOST:      smtp.sendgrid.net
    PROXY_SMTP_PORT:      465
    PROXY_SMTP_AUTH:      PLAIN
    PROXY_SMTP_FROM:      events@uware.co

## Launch

In this directory, run:

    eval $(docker-machine env elk) ## or whatever you call your docker machine
    docker-compose build
    docker-compose up -d

You should now be able to browse to the IP address of the docker machine you created.

To re-build and re-deploy one of the services in this stack:

    docker-compose build SERVICE
    docker-compose up --no-deps -d SERVICE

where SERVICE is one of elasticsearch, logs, kibana or proxy.
