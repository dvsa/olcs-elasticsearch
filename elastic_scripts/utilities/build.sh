#!/bin/bash

usage() {
    echo;
    echo Usage: build.sh [options];
    echo;
    echo "-c file PHP config file containined eg local.php";
    echo "-nX The new version of the index to create";
    echo "-p  Promote new index, assign it the alias and delete the old index";
    echo '-s  Runs non interactive, no prompts';
    echo '-dX Number of seconds delay when checking if rivers are complete';
    echo '-rX Number of miuntes between the indexes updating themselves';
    echo '-mX Database name'
    echo '-t  Test mode, just use the irfo index'
    echo '-h  Display usage (this)';
    exit;
}

interactive=true
delay=600 # seconds
reindex=15 # minutes
INDEXES=( "address" "application" "busreg" "case" "irfo" "licence" "operator" "person" "pi_hearing" "psv_disc" "publication" "recipient" "user" "vehicle_current" "vehicle_removed" )

while getopts ":c:n:d:r:m:psht" opt; do
  case $opt in
    c)
        configFile=$OPTARG
      ;;
    n)
        newVersion=$OPTARG
      ;;
    p)
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
    m)
        DBNAME=$OPTARG
      ;;
    t)
        INDEXES=( "irfo" )
      ;;
    h)
        usage;
        ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage;
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage;
      ;;
  esac
done

if [ -z "$DBNAME" ]
then
    echo -m '$DBNAME' variable must be set
    exit;
fi

if [ -z "$configFile" ]
then
    echo -c '$configFile' variable must be set
    exit;
fi


echo ==================================================
echo $(date)

# parse db user and password out of php config
DBUSER=$(php -r "\$config=require('$configFile'); echo \$config['doctrine']['connection']['orm_default']['params']['user'];")
DBPASSWORD=$(php -r "\$config=require('$configFile'); echo \$config['doctrine']['connection']['orm_default']['params']['password'];")
#DBNAME=$(php -r "\$config=require('$configFile'); echo \$config['doctrine']['connection']['orm_default']['params']['dbname'];")
DBHOST=$(php -r "\$config=require('$configFile'); echo \$config['doctrine']['connection']['orm_default']['params']['host'];")

echo DBHOST = $DBHOST
echo DBNAME = $DBNAME
echo configFile = $configFile

ELASTIC_HOST=$(php -r "\$config=require('$configFile'); echo \$config['elastic_search']['host'];")
echo ELASTIC_HOST = $ELASTIC_HOST

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
done





echo ==================================================
echo $(date)
echo ================ CREATE RIVERS ===================
for index in "${INDEXES[@]}"
do
    echo $index
    cd ../$index
    source ../utilities/createIndexRiver.sh $DBHOST $DBNAME $DBUSER $DBPASSWORD $index $newVersion
done





echo ==================================================
echo $(date)
echo ============== CHECK RIVERS COMPLETE =============
while true; do
    # wait X seconds before checking
    sleep $delay

    response=$(curl -XGET -s "http://$ELASTIC_HOST:9200/_river/jdbc/*/_state?pretty=1")

    if [[ "$response" == *"\"active\" : true"* ]]; then
        number_of_occurrences=$(grep -o "\"active\" : true" <<< "$response" | wc -l)
        echo $(date) $number_of_occurrences rivers active
    else
        break;
    fi
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
source viewIndexStats.sh | php viewIndexStats.php





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
