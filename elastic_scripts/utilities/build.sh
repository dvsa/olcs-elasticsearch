#!/bin/bash

usage() {
    if [ -n "$1" ]; then
        echo;
        echo Error : $1
    fi

    echo;
    echo Usage: build.sh [options];
    echo;
    echo "-e hostname   : Elasticsearch server hostname";
    echo "-h dbname     : Database host";
    echo "-u dbuser     : Database user";
    echo "-p dbpassword : Database password";
    echo '-m dbname     : Database name'
    echo "-l            : Promote new index, assign it the alias and delete the old index";
    echo '-s            : Runs non interactive, no prompts';
    echo '-d seconds    : Number of seconds delay when checking if rivers are complete';
    echo '-r minutes    : Number of minutes between the indexes updating themselves';
    echo "-n version    : The new version of the index to create (TESTING ONLY)";
    echo '-i n/a        : Index to use irfo (TESTING ONLY)'
    exit;
}

interactive=true
delay=60 # seconds
reindex=60 # minutes
newVersion=$(date +%s) #timestamp


while getopts ":c:e:h:u:p:m:d:r:n:ils" opt; do
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
    s)
        interactive=false
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



echo ==================================================
echo $(date)
echo ==================================================
echo ELASTIC_HOST = $ELASTIC_HOST
echo DBHOST = $DBHOST
echo DBNAME = $DBNAME
echo Working on indexes: ${INDEXES[@]}
echo Delay = $delay seconds
echo Reindex = $reindex miuntes
echo New version = $newVersion
echo ==================================================



if [ "$interactive" == "true" ]; then
    echo
    read -p "Press [Enter] key to start..."
    echo
fi





echo ==================================================
echo $(date)
echo ======= DELETE INDEXES WITHOUT AN ALIAS ==========
cd ../utilities
indexsWithoutAlias=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases | python ./py/indexWithoutAlias.py ${INDEXES[@]})
if [ ! -z $indexsWithoutAlias ]; then
    echo Deleting Index without aliases : $indexsWithoutAlias
    curl -XDELETE -s $ELASTIC_HOST:9200/$indexsWithoutAlias
fi







echo ==================================================
echo $(date)
echo ========== DELETE SCHEDULED RIVERS ===============
cd ../utilities
for index in "${INDEXES[@]}"
do
    echo $index
    source deleteNamedRiver.sh $index
done





echo ==================================================
echo $(date)
echo ================= CREATE INDEXES =================
for index in "${INDEXES[@]}"
do
    echo $index
    cd ../$index
    source createIndex.sh $newVersion
    echo
done





echo ==================================================
echo $(date)
echo ============== POPULATE INDEXES ==================
for index in "${INDEXES[@]}"
do
    echo $index
    cd ../$index
    source ../utilities/createIndexRiver.sh $DBHOST $DBNAME $DBUSER $DBPASSWORD $index $newVersion
    echo

    lastNumberOfDocs=0
    while true; do
        # wait X seconds before checking
        sleep $delay

        numberOfDocs=$(curl -XGET -s "http://$ELASTIC_HOST:9200/${index}_v${newVersion}/_status?pretty=1" | python ../utilities/py/getDocCount.py ${index}_v${newVersion})
        echo Number of documents in ${index}_v${newVersion} = $numberOfDocs
        if [ $numberOfDocs -eq 0 ]; then
            continue
        fi

        if [ $lastNumberOfDocs -eq $numberOfDocs ]; then
            echo Document count not changed, assuming river is complete
            break;
        fi

        lastNumberOfDocs=$numberOfDocs
    done
done





echo ==================================================
echo $(date)
echo =============== DELETING RIVERS ==================
cd ../utilities
for index in "${INDEXES[@]}"
do
    echo $index
    source deleteNamedRiver.sh $index
done




echo
echo ==================================================
echo $(date)
echo ================= INDEX STATS ====================
cd ../utilities
source viewIndexStats.sh > temp.json
python ./py/checkIndexes.py $newVersion ${INDEXES[@]}
if [ $? -ne 0 ]; then
    echo "Errors in indexes, therefore stopping"
    exit 1;
fi






echo ==================================================
echo $(date)
echo =========== CREATE SCHEDULED RIVERS ==============
for index in "${INDEXES[@]}"
do
    startMinute=$(( ( RANDOM % $reindex ) ))
    echo $index
    cd ../$index
    source ../utilities/createIndexRiver.sh $DBHOST $DBNAME $DBUSER $DBPASSWORD $index $newVersion $startMinute/$reindex
done





echo
if [ "$promoteNewIndex" != "true" ]; then
    echo NOT promoting new index
    exit
else
    if [ "$interactive" == "true" ]; then
        echo
        read -p "Press [Enter] key to promote new indexes..."
        echo
    fi
fi





echo ==================================================
echo $(date)
echo ============= MOVE ALIAS TO NEW INDEX ============
cd ../utilities
modifyBody=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases?pretty=1 | python ./py/modifyAliases.py $newVersion ${INDEXES[@]})
response=$(curl -XPOST -s $ELASTIC_HOST':9200/_aliases' -d "$modifyBody")
if [[ $response != "{\"acknowledged\":true}" ]]; then
    echo $response
    exit 1
fi





echo ==================== DONE ========================
echo $(date)
