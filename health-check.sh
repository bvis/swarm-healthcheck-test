#!/bin/sh

TTL=30

LAUNCHED=$(stat -c %Y /init.pid)
CURRENT=$(date +%s)

ALIVE=$(expr $CURRENT - $LAUNCHED)

if [ $ALIVE -lt $TTL ]; then
  exit 1
else
  exit 0
fi
