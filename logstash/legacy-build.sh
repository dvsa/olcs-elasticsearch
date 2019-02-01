#!/bin/bash

usage() {
    if [ -n "$1" ]; then
        echo;
        echo Error : $1
    fi

    echo;
    echo Usage: build.sh [options];
    echo;
    echo "-c <file>     : bash file containing config";
    echo "-f <file>     : File to generate eg /etc/logstash/populate_indices.conf";
    echo "-l            : Promote new index, assign it the alias and delete the old index";
    echo '-d <seconds>  : Number of seconds delay when checking if rivers are complete';
    echo '-i <index>    : Only rebuild one index'
    echo
    exit;
}

log() {
    if [ "$logfile" == "" ]; then
        echo -e $(date) $1
    else
        echo $(date) >> $logfile
        echo -e $1 >> $logfile
    fi
    logger $1
}


delay=70 # seconds
reindex=60 # minutes
newVersion=$(date +%s) #timestamp
CONF_FILE=populate_indices.conf

while getopts "c:f:d:n:i:l" opt; do
  case $opt in
    c)
        if [ ! -f $OPTARG ]; then
          usage "Config file $OPTARG doesn't exist";
        fi
        source $OPTARG
      ;;
    f)
        if [ ! -f $OPTARG ]; then
          usage "Conf file doesn't exist";
        fi
        CONF_FILE=$OPTARG
      ;;
    l)
        promoteNewIndex=true
      ;;
    d)
        delay=$OPTARG
      ;;
    n)
        newVersion=$OPTARG
      ;;
    i)
        INDEXES=( "$OPTARG" )
      ;;
    \?)
      usage "Invalid option: -$OPTARG";
      ;;
    :)
      usage "Option -$OPTARG requires an argument.";
      ;;
  esac
done

if [ -z "$ELASTIC_HOST" ]
then
    usage "ELASTIC_HOST must be specified in config file"
    exit;
fi


if [ -z "$INDEXES" ]
then
    INDEXES=( "address" "application" "busreg" "case" "irfo" "licence" "person" "psv_disc" "publication" "user" "vehicle_current" "vehicle_removed" )
fi


LOCKFILE=$(readlink -m build.lock)
if [ -f $LOCKFILE ]; then
  log "It appears this script is already running, if you believe this is incorrect you can manually delete the lock file '$LOCKFILE'"
  exit;
fi
touch $LOCKFILE

log "Config:\n
CONF_FILE: $CONF_FILE\n
Working on indexes: ${INDEXES[*]}\n
Delay = $delay seconds\n
Reindex = $reindex miuntes\n
New version = $newVersion
"


log "DELETE INDEXES WITHOUT AN ALIAS"
indexsWithoutAlias=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases | python ./py/indexWithoutAlias.py ${INDEXES[@]})
if [ ! -z $indexsWithoutAlias ]; then
    log "Deleting Indexes without aliases : $indexsWithoutAlias"
    response=$(curl -XDELETE -s $ELASTIC_HOST:9200/$indexsWithoutAlias)
    if [[ $response != "{\"acknowledged\":true}" ]]; then
        log "$response"
        echo "ERROR $response"
        rm -f $LOCKFILE
        exit 1
    fi
fi

/etc/init.d/logstash stop
log "Alter config file for new alias version ${newVersion}"
for index in "${INDEXES[@]}"
do
    sed "s/index => \"${index}_v[0-9]*\"/index => \"${index}_v${newVersion}\"/" -i $CONF_FILE
    rm -f /etc/logstash/lastrun/${index}.lastrun
done
/etc/init.d/logstash start


log "POPULATE INDEXES"
for index in "${INDEXES[@]}"
do
    lastSize=0
    while true; do
        # wait X seconds before checking
        sleep $delay

        size=$(curl -XGET -s "http://$ELASTIC_HOST:9200/${index}_v${newVersion}/_stats" | python ./py/getIndexSize.py)
        log "${index}_v${newVersion} size = $size"
        if [ "$size" -lt 10 ]; then
            continue
        fi

        if [ "$lastSize" == "$size" ]; then
            log "Index document count not changed, assuming index is fully populated"
            break;
        fi

        lastSize=$size
    done
done


log "INDEX STATS"
curl -XGET -s "http://$ELASTIC_HOST:9200/_cat/indices"


if [ "$promoteNewIndex" != "true" ]; then
    echo "Done NOT promoting new index"
    rm -f $LOCKFILE
    exit
fi


log "MOVE ALIAS TO NEW INDEX"
modifyBody=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases?pretty=1 | python ./py/modifyAliases.py $newVersion ${INDEXES[@]})
response=$(curl -XPOST -s $ELASTIC_HOST':9200/_aliases' -d "$modifyBody")
if [[ $response != "{\"acknowledged\":true}" ]]; then
    log "$response"
    echo "ERROR $response"
    rm -f $LOCKFILE
    exit 1
fi

log "Enable replicas"
curl -s -XPUT "http://$ELASTIC_HOST:9200/_settings" -H 'Content-Type: application/json' -d '{"index": {"number_of_replicas": 1}}'

rm -f $LOCKFILE
echo "Done"
