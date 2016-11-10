#!/bin/bash

CONSUMER_KEY="dE1Hj15LPMAEVVEVVle0hJ2J2"
CONSUMER_SECRET="ht4vWSMqlM3T691rDRY2tR4OfFwRR46gjoAB7Ffyvu5QWUvxaU"
CALLBACK="http://localhost:3001/callback"
TIMESTAMP=$(date +"%s")
NONCE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
SIGNATURE=""

echo $CALLBACK
echo $TIMESTAMP
echo $NONCE



# fire
#curl \
#  -X POST                                               \
#  -H "User-Agent: foo HTTP Client"                      \
#  -H "Content-type: application/json"                   \
#  -H "Authorization: OAuth "                            \
#  -H "oauth_callback=$CALLBACK"                                  \
#  -H "oauth_consumer_key=$CONSUMER_KEY"                              \
#  -H "oauth_nonce=$NONCE"                                     \
#  -H "oauth_signature=$SIGNATURE"                                 \
#  -H "oauth_signature_method=HMAC-SHA1"                 \
#  -H "oauth_timestamp=$TIMESTAMP"                       \
#  -H "oauth_version=1.0"                                \
#  "https://api.twitter.com/oauth/request_token"

exit 0
