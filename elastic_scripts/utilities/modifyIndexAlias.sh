alias=$1
index=$2
version=$3
# action is "remove" or "add"
action=${4:-add}

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
