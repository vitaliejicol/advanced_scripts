#!/usr/bin/env bash

# Always first argument should be the ipaddr
# After second arguments all should be hosts


IP_RESULT=$(dig -x "$1" +noall +answer |tail -n1 |  grep -v '+cmd' | awk '{ print $NF}')

if [[ "$IP_RESULT" ]]; then
  echo "Checking IP was success"
else
  echo "IP is not working"
  exit 1
fi


HOST="${@:2}"
for i in ${HOST}; do
  RESULT=$(dig "$i" +short)

  if [[ "$RESULT" ]]; then
    echo "Checking host was success"
  else
    echo "Host is not working"
    exit 1
  fi
done
