#!/bin/bash
#
# name: mkcertreq
# version: 0.2
# parameter(s): SITE_NAME
# usage: mkcertreq site.utoronto.ca
# options: {pending}
#
# purpose: Takes a site name/address as an option and generates server key
#   and certificate request files.  Creates files under a cert directory
#   that is also tarred up for archival purposes.  The cert request is
#   generated with sha256. Future releases can be parametrized or include
#   options for cert request inputs and file output control.
#
# output: Aside from server.* files that are archived and placed on crush,
#   the server.csr is also emailed to eis.wss@utoronto.ca shared mailbox.
#
###############################################################################

if [ "$#" -ne 1 ]; then
  echo "Incorrent number of arguments."
  echo "Did you forget to provide the site name?"
  exit 1
fi

# Assign arguments to variables.
SITE_NAME=$1

# Appending year is a good practice
certdir=/root/certs/ssl.crt.$1.precert.`date +"%Y"`.SHA2
mkdir $certdir
# Change dir to work dir
cd $certdir
# Genereate a random string for the passphrase
phrase=`date +%s | sha256sum | base64 | head -c 32 ; echo`
pathphrase=pass.$1.`date +"%Y"`
echo $phrase > $pathphrase
chmod 600 $pathphrase
# Generate an encrypted key
/usr/bin/openssl genrsa -des3 -out server.key.encrypted -passout file:$pathphrase 2048
## Apply a passphrase and note it down to be used later to generate the .csr
/usr/bin/openssl rsa -noout -text -in server.key.encrypted -passin file:$pathphrase
## display it if you like BUT don't save output in a log!!!!
/usr/bin/openssl rsa -in server.key.encrypted -out server.key -passin file:$pathphrase
chmod 600 server.key
# Generate the server request by accepting input in following lines
/usr/bin/openssl req -new -key server.key -out server.csr -sha256 << EOF
CA
Ontario
Toronto
University of Toronto
ITS
$SITE_NAME
sarosh.jamal@utoronto.ca
itseissig
.
EOF

## Display the SUBJECT line from new cert request
openssl req -noout -text -in server.csr | grep -i "Subject\:"
## Secure permissions on generated files
chmod 600 server.*
## save and backup everything so far
cd ..
tarname=$certdir.precert.tar.gz
tar cvplzf $tarname $certdir
chmod 600 $tarname
#scp -i /home/pctl/.ssh/crushcerts -p -P 2222 $tarname tomcat@crush.easi.utoronto.ca:/certs
# Email the cert replacement request with site name on 1st line and cert on 3rd line
certreqonly=`grep -v -E "BEGIN|END" $certdir/server.csr`
certreq=`cat $certdir/server.csr`
requrl="http://sites.utoronto.ca/security/services/server_certs.htm"
echo -e "$1\n\n$certreq\n\n$requrl" | mail -s "SHA-2 TLS cert request" sarosh.jamal@utoronto.ca

### END ###
