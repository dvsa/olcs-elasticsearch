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
INDEXES=( "address" "application" "busreg" "case" "irfo" "licence" "operator" "person" "pi_hearing" "psv_disc" "publication" "recipient" "user" "vehicle_current" "vehicle_removed" )

while getopts ":e:h:u:p:m:d:r:n:ils" opt; do
  case $opt in
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



echo ==================================================
echo $(date)


echo ELASTIC_HOST = $ELASTIC_HOST
echo DBHOST = $DBHOST
echo DBNAME = $DBNAME
echo Working on indexes: ${INDEXES[@]}
echo Delay = $delay seconds
echo Reindex = $reindex miuntes




echo ============== DETECT INDEX VERSION ==============

if [ "$newVersion" == "" ]; then
    response=$(curl -XGET -s "$ELASTIC_HOST:9200/_aliases?pretty=1")
    number_of_v1=$(grep -o "_v1" <<< "$response" | wc -l)
    number_of_v2=$(grep -o "_v2" <<< "$response" | wc -l)

    if [ $number_of_v1 -eq 0 ]; then
        newVersion=1
    elif [ $number_of_v2 -eq 0 ]; then
        newVersion=2
    else
        echo ERROR : Cannot detect which version to use
        echo There are $number_of_v1 V1 indexes and $number_of_v2 V2 indexes.
        exit 1
    fi
fi

if [ "$newVersion" == "1" ]; then
    oldVersion=2
else
    oldVersion=1
fi

echo New version is $newVersion, to replace old version $oldVersion

if [ "$interactive" == "true" ]; then
    echo
    read -p "Press [Enter] key to start..."
    echo
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

    while true; do
        # wait X seconds before checking

        sleep $delay
        response=$(curl -XGET -s "http://$ELASTIC_HOST:9200/_river/jdbc/olcs_${index}_river/_state?pretty=1")
        if [[ "$response" == *"\"active\" : true"* ]]; then
            #number_of_occurrences=$(grep -o "\"active\" : true" <<< "$response" | wc -l)
            echo $(date) Still active
        else
            break;
        fi
    done
done
echo $(date) All Rivers complete





echo ==================================================
echo $(date)
echo =============== DELETING RIVERS ==================
cd ../utilities
for index in "${INDEXES[@]}"
do
    echo $index
    source deleteNamedRiver.sh $index
done








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




echo ==================================================
echo $(date)
echo ================= INDEX STATS ====================
cd ../utilities
source viewIndexStats.sh > temp.json
python checkIndexes.py
if [ $? -ne 0 ]; then
    echo "Errors in indexes, therefore stopping"
    exit 1;
fi





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
for index in "${INDEXES[@]}"
do
    response=$(curl -XPOST -s $ELASTIC_HOST':9200/_aliases' -d '
    {
        "actions" : [
            { "remove" : { "index" : "'$index'_v'$oldVersion'", "alias" : "'$index'" } },
            { "add"    : { "index" : "'$index'_v'$newVersion'", "alias" : "'$index'" } }
        ]
    }')
    if [[ $response != "{\"acknowledged\":true}" ]]; then
        echo $response
        exit 1
    fi
done





echo ==================================================
echo $(date)
echo ============= DELETING OLD INDEXES ===============
cd ../utilities
for index in "${INDEXES[@]}"
do
    echo $index
    source deleteNamedIndex.sh $index $oldVersion
done





echo ==================== DONE ========================
echo $(date)
