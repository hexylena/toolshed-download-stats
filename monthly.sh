#!/bin/bash
YEAR=$(date '+%Y')
MONTH=$(date '+%m')
FOLDER="monthly/${YEAR}/${MONTH}/"
mkdir -p "${FOLDER}"

curl https://toolshed.g2.bx.psu.edu/api/repositories > repos.json
cat repos.json| jq '[.[] | {"key": (.owner +"/" + .name), "value": (.times_downloaded) }] | from_entries' -S > "${FOLDER}/downloads.json"
cat repos.json| jq '.[] | [.owner +"/" + .name, .times_downloaded] | @tsv' -r > "${FOLDER}/downloads.tsv"

cat repos.json | jq '[.[] | {"owner": .owner, "dls": .times_downloaded}] | group_by(.owner) | map({"key": first.owner, "value": (map(.dls) | add)}) | from_entries' > "${FOLDER}/downloads-by-user.json"
cat repos.json | jq '[.[] | {"owner": .owner, "dls": .times_downloaded}] | group_by(.owner) | map([first.owner, (map(.dls) | add)]) | .[] | @tsv' -r > "${FOLDER}/downloads-by-user.tsv"
