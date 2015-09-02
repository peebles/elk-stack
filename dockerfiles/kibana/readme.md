# Kibana

## Preperation

Access to Kibana will be encrypted over HTTPS.  Therefore you need a server.key and a server.crt.  This
Dockerfile assumes those two files exist and will copy them into the image.  If you do not have your own
server.key and server.crt, you can generate self-signed versions like this:

    sudo openssl genrsa -des3 -out server.key 1024
    sudo openssl req -new -key server.key -out server.csr
    sudo cp server.key server.key.org
    sudo openssl rsa -in server.key.org -out server.key
    sudo openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

Just give a consistent password each time you are prompted for one.

