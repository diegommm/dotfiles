#!/bin/bash

# clone all relevant repos from a GitHub Organization

set -e

ORG=${1:?}

list(){
    # 1. Go to https://github.com/orgs/$ORG/repositories
    # 2. Open the network tab in dev console
    # 3. Make the following search mirror:false fork:false archived:false sort=updated
    # 4. Copy as cURL the resulting API call and use it to replace the line below these comments
    # 5. Change the `page=1'` part of the URL with `page='$1`
    #curly commandy :)
}

cd ~/go/srg/github.com
mkdir -p $ORG
cd $ORG

rm -f page-*.json

for x in $(seq 1 41); do
    list $x 2> /dev/null > page-$x.json || echo failed page $x
done;

for x in page-[1-9].json; do mv $x page-0${x//*-}; done

jq -r '.repositories[] | .name' page-*.json |
    while read x; do
        [ -e "$x" ] || git clone git@github.com:$ORG/$x.git || true
    done
