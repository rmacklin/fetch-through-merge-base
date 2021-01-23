#!/bin/sh

DEEPEN_LENGTH=${DEEPEN_LENGTH:-10}

git fetch --progress --depth=1 origin "+refs/heads/$BASE_REF:refs/heads/$BASE_REF"
while [ -z "$( git merge-base "$BASE_REF" "$HEAD_REF" )" ]; do
  git fetch -q --deepen="$DEEPEN_LENGTH" origin "$BASE_REF" "$HEAD_REF";
done
