#!/bin/sh

git fetch --progress --depth=1 origin "+refs/heads/$BASE_REF:refs/heads/$BASE_REF"
while [ -z "$( git merge-base "$BASE_REF" "$HEAD_REF" )" ]; do
  git fetch -q --deepen=10 origin "$BASE_REF" "$HEAD_REF";
done
