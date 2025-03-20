#!/bin/bash

# clone all relevant repos from a GitHub Organization

set -e

ORG="${1:?Expecting GitHub Org handle as first arg}";

list(){
    # 1. Go to https://github.com/orgs/$ORG/repositories
    # 2. Open the network tab in dev console
    # 3. Make the following search: `mirror:false fork:false archived:false sort:updated`
    # 4. Copy as cURL the resulting API call and use it to replace the line below these comments
    # 5. Change the `page=1'` part of the URL with `page='$1`
    #curly commandy :)
}

cd ~/go/src/github.com;
mkdir -p "${ORG}";
cd "${ORG}";

rm -f repos-page-*.json;

x=1;
while true; do
    xx="${x}";
    if [[ "${x}" -lt 100 ]]; then
        xx="0${xx}";
        if [[ "${x}" -lt 10 ]]; then
            xx="0${xx}";
        fi;
    fi;
    if list "${x}" 2> /dev/null > "repos-page-${xx}.json"; then
        if ! jq -r '.repositories[] | .name' "repos-page-${xx}.json" | grep -q .; then
            rm -f "repos-page-${xx}.json";
            break;
        fi;
    else
        echo "failed page ${x}";
    fi;
    x=$(( 1 + x ));
done;

jq -r '.repositories[] | .name' repos-page-*.json |
    while read -r x; do
        [[ -e "${x}" ]] || git clone "git@github.com:${ORG}/${x}.git" || true
    done
