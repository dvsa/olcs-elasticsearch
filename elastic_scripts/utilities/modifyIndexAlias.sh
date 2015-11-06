#!/bin/bash

alias=$1
index=$2
version=$3
# action is "remove" or "add"
action=${4:-add}

if [ "$#" -lt 3 ]; then
    echo "Parameters must include <alias> <index> <version> <optional - action add(default) or remove>"
    exit 1
fi

curl -XPOST localhost:9200/_aliases -d '
{
    "actions": [
        { "'"$action"'": {
            "alias": "'"$alias"'",
            "index": "'"$index"'_v'"$version"'"
        }}
    ]
}
'
