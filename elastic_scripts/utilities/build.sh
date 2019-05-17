#!/bin/bash

usage() {
    if [ -n "$1" ]; then
        echo;
        echo Error : $1
    fi

    echo;
    echo Usage: build.sh [options];
    echo;
    echo "-c file       : bash file containing config";
    echo "-e hostname   : Elasticsearch server hostname";
    echo "-h dbname     : Database host";
    echo "-u dbuser     : Database user";
    echo "-p dbpassword : Database password";
    echo '-m dbname     : Database name'
    echo "-l            : Promote new index, assign it the alias and delete the old index";
    echo '-d seconds    : Number of seconds delay when checking if rivers are complete';
    echo '-r minutes    : Number of minutes between the indexes updating themselves';
    echo "-n version    : The new version of the index to create (TESTING ONLY)";
    echo '-i n/a        : Index to use irfo (TESTING ONLY)'
    exit;
}

log() {
    if [ "$logfile" == "" ]; then
        echo -e $(date) $1
    else
        echo $(date) >> $logfile
        echo -e $1 >> $logfile
    fi
}


delay=180 # seconds
reindex=60 # minutes
newVersion=$(date +%s) #timestamp

while getopts ":c:e:h:u:p:m:d:r:n:il" opt; do
  case $opt in
    c)
        source $OPTARG
      ;;
    e)
        ELASTIC_HOST=$OPTARG
      ;;
    h)
        DBHOST=$OPTARG
      ;;
    u)
        DBUSER=$OPTARG
      ;;
    p)
        DBPASSWORD=$OPTARG
      ;;
    m)
        DBNAME=$OPTARG
      ;;
    l)
        promoteNewIndex=true
      ;;
    d)
        delay=$OPTARG
      ;;
    r)
        reindex=$OPTARG
      ;;
    n)
        newVersion=$OPTARG
      ;;
    i)
        INDEXES=( "irfo" )
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
    usage "-e parameter must be set"
    exit;
fi

if [ -z "$DBHOST" ]
then
    usage "-h parameter must be set"
    exit;
fi

if [ -z "$DBNAME" ]
then
    usage "-m parameter must be set"
    exit;
fi

if [ -z "$DBUSER" ]
then
    usage "-u parameter must be set"
    exit;
fi

if [ -z "$DBPASSWORD" ]
then
    usage "-p parameter must be set"
    exit;
fi

if [ -z "$INDEXES" ]
then
    INDEXES=( "address" "application" "busreg" "case" "irfo" "licence" "operator" "person" "pi_hearing" "psv_disc" "publication" "recipient" "user" "vehicle_current" "vehicle_removed" )
fi

LOCKFILE=$(readlink -m build.lock)
if [ -f $LOCKFILE ]; then
  log "It appears this script is already running, if you believe this is incorrect you can manually delete the lock file '$LOCKFILE'"
  exit;
fi
touch $LOCKFILE

log "Config:\n
ELASTIC_HOST = $ELASTIC_HOST\n
DBHOST = $DBHOST\n
DBNAME = $DBNAME\n
Working on indexes: ${INDEXES[*]}\n
Delay = $delay seconds\n
Reindex = $reindex miuntes\n
New version = $newVersion
"


log "DELETE SCHEDULED RIVERS"
cd ../utilities
for index in "${INDEXES[@]}"
do
    response=$(curl -XDELETE -s $ELASTIC_HOST:9200/_river/olcs_${index}_river)
    #if [[ $response != "{\"acknowledged\":true}" ]]; then
    #    log "$response"
    #fi
done


log "DELETE INDEXES WITHOUT AN ALIAS"
cd ../utilities
indexsWithoutAlias=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases | python2.7 ./py/indexWithoutAlias.py ${INDEXES[@]})
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


log "CREATE INDEXES"
for index in "${INDEXES[@]}"
do
    cd ../$index
    source createIndex.sh $newVersion
    if [[ $response != "{\"acknowledged\":true}" ]]; then
        log "$response"
        echo "ERROR $response"
        rm -f $LOCKFILE
        exit 1
    fi
done


log "POPULATE INDEXES"
for index in "${INDEXES[@]}"
do
    cd ../$index
    source ../utilities/createIndexRiver.sh $DBHOST $DBNAME $DBUSER $DBPASSWORD $index $newVersion

    lastSize=0
    while true; do
        # wait X seconds before checking
        sleep $delay

        size=$(curl -XGET -s "http://$ELASTIC_HOST:9200/${index}_v${newVersion}/_status?pretty=1" | python2.7 ../utilities/py/getIndexSize.py ${index}_v${newVersion})
        log "${index}_v${newVersion} size = $size"
        if [ "$size" -lt 1000 ]; then
            continue
        fi

        if [ "$lastSize" == "$size" ]; then
            log "Index size not changed, assuming river is complete"
            break;
        fi

        lastSize=$size
    done
done


log "DELETING RIVERS"
cd ../utilities
for index in "${INDEXES[@]}"
do
    response=$(curl -XDELETE -s $ELASTIC_HOST:9200/_river/olcs_${index}_river)
    if [[ $response != "{\"acknowledged\":true}" ]]; then
        log "$response"
    fi
done


log "INDEX STATS"
cd ../utilities
source viewIndexStats.sh > temp.json
python2.7 ./py/checkIndexes.py $newVersion ${INDEXES[@]}
if [ $? -ne 0 ]; then
    log "Major differences in some index document counts need investigation."
fi


log "CREATE SCHEDULED RIVERS"
for index in "${INDEXES[@]}"
do
    startMinute=$(( ( RANDOM % $reindex ) ))
    cd ../$index
    source ../utilities/createIndexRiver.sh $DBHOST $DBNAME $DBUSER $DBPASSWORD $index $newVersion $startMinute/$reindex
done


if [ "$promoteNewIndex" != "true" ]; then
    echo "Done NOT promoting new index"
    rm -f $LOCKFILE
    exit
fi


log "MOVE ALIAS TO NEW INDEX"
cd ../utilities
modifyBody=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases?pretty=1 | python2.7 ./py/modifyAliases.py $newVersion ${INDEXES[@]})
response=$(curl -XPOST -s $ELASTIC_HOST':9200/_aliases' -d "$modifyBody")
if [[ $response != "{\"acknowledged\":true}" ]]; then
    log "$response"
    echo "ERROR $response"
    rm -f $LOCKFILE
    exit 1
fi

rm -f $LOCKFILE
echo "Done"
