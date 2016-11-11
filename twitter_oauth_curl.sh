#!/bin/bash

## GLOBALS 

CONSUMER_KEY="dE1Hj15LPMAEVVEVVle0hJ2J2"
CONSUMER_SECRET="ht4vWSMqlM3T691rDRY2tR4OfFwRR46gjoAB7Ffyvu5QWUvxaU"
CALLBACK="http://localhost:3001/callback"
TIMESTAMP=$(date +"%s")
NONCE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# generate an OAuth 1.0a HMAC-SHA1 signature for a HTTP request
URL="https://api.twitter.com/oauth/request_token"
METHOD="POST"
SIGNATURE_METHOD="HMAC-SHA1"
SIGNATURE=""

## FUNCTIONS
encode_string() {
	local encode_str_result=""
	local str="${1}"
	local str_length=${#str}

	local pos char encodedchar
	for(( pos=0 ; pos<str_length ; pos++ )); do
		char=${str:$pos:1}
		case "$char" in
			[-_.~a-zA-Z0-9] )   encodedchar="${c}" ;;
			* )                 printf -v encodedchar '%%%02x' "'$char"
		esac
		encode_str_result+="${encodedchar}"
	done

	echo "${encode_str_result}"

	# set result to global - no return values I'm afraid
	ENCODED_STR="${encode_str_result}"
}

rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

create_signature() {
    local sig=""
    local url="${URL}"
    local method="${METHOD}" 

    # build params
    sig+="oauth_consumer_key=${CONSUMER_KEY}&"
    sig+="oauth_nonce=${NONCE}&"
    sig+="oauth_signature_method=${SIGNATURE_METHOD}&"
    sig+="oauth_timestamp=${TIMESTAMP}&"

    # oauth_token - shouldn't this have been obtained by user granting permission?
    sig+="oauth_token=${CONSUMER_SECRET}&"
    sig+="oauth_version=1.0"

    #encode
    sig=$( rawurlencode "$sig" )
    url=$( rawurlencode "$url" ) 

    #create 
    SIGNATURE="${method}&${url}&${sig}"

    # use openssl lib to create SHA1 hash
    # echo -n "value" | openssl sha1 -hmac "key"

}

create_signature

####
echo CONSUMER_KEY: $CONSUMER_KEY
echo CONSUMER_SECRET: $CONSUMER_SECRET
echo CALLBACK: $( rawurlencode "$CALLBACK" )
echo TIMESTAMP: $TIMESTAMP
echo NONCE: $NONCE
echo URL: $( rawurlencode "$URL" )
echo SIGNATURE: $SIGNATURE




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
