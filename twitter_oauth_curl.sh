#!/bin/bash

## GLOBALS 

CONSUMER_KEY="dE1Hj15LPMAEVVEVVle0hJ2J2"
CONSUMER_SECRET="ht4vWSMqlM3T691rDRY2tR4OfFwRR46gjoAB7Ffyvu5QWUvxaU"
CALLBACK="http://localhost:3001/callback"
TIMESTAMP=$(date +"%s")
NONCE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# generate an OAuth 1.0a HMAC-SHA1 signature for a HTTP request
URL="https://api.twitter.com/oauth/request_token"
BASEURL="https://api.twitter.com/oauth"
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
    local url="${BASEURL}${1}"
    local sig=""
    # if second arg provided, this is the token secret provided
    # local key="" || ${2}
    local key=$( rawurlencode "$CONSUMER_SECRET" )
    local method="${METHOD}" 

    # build params
    sig+="oauth_consumer_key=${CONSUMER_KEY}&"
    sig+="oauth_nonce=${NONCE}&"
    sig+="oauth_signature_method=${SIGNATURE_METHOD}&"
    sig+="oauth_timestamp=${TIMESTAMP}&"

    # oauth_token - shouldn't this have been obtained by user granting permission?
    # - NO: can't do this at request_token stage
    # sig+="oauth_token=${CONSUMER_SECRET}&"
    sig+="oauth_version=1.0"

    #encode
    sig=$( rawurlencode "$sig" )
    url=$( rawurlencode "$url" ) 

    #create 
    SIGNATURE=`echo -n "${method}&${url}&${sig}" | openssl dgst -sha1 -hmac "${key}&" | sed 's/^.* //'`

    # use openssl lib to create SHA1 hash
    # echo -n "value" | openssl sha1 -hmac "key"

}

create_signature "/request_token"
CALLBACK=$( rawurlencode "$CALLBACK" )

# fire
curl \
  -I \
  -v \
  -X POST \
  -H "User-Agent: FooBar HTTP Client" \
  -H "Content-Type: application/json" \
  -H "Authorization: OAuth oauth_callback=\"$CALLBACK\",oauth_consumer_key=\"$CONSUMER_KEY\",oauth_nonce=\"$NONCE\",oauth_signature=\"$SIGNATURE\",oauth_signature_method=\"$SIGNATURE_METHOD\",oauth_timestamp=\"$TIMESTAMP\",oauth_version=\"1.0\"" \
  "$BASEURL/request_token"

exit 0
