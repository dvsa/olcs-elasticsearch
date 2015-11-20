#!/bin/bash

usage() {
    echo;
    echo Usage: build.sh [options] -c file;
    echo;
    echo "-nX The new version of the index to create";
    echo "-p  Promote new index, assign it the alias and delete the old index";
    echo '-s  Runs non interactive, no prompts';
    echo '-h  Display usage (this)';
    exit;
}

interactive=true

while getopts ":n:psh" opt; do
  case $opt in
    n)
        newVersion=$OPTARG
      ;;
    p)
        promoteNewIndex=true
      ;;
    s)
        interactive=false
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

echo ==================================================
echo $(date)

# parse db user and password out of php config
DBUSER=$(php -r "\$config=require('config/local.php'); echo \$config['doctrine']['connection']['orm_default']['params']['user'];")
DBPASSWORD=$(php -r "\$config=require('config/local.php'); echo \$config['doctrine']['connection']['orm_default']['params']['password'];")
DBNAME=$(php -r "\$config=require('config/local.php'); echo \$config['doctrine']['connection']['orm_default']['params']['dbname'];")
DBHOST=$(php -r "\$config=require('config/local.php'); echo \$config['doctrine']['connection']['orm_default']['params']['host'];")
echo DBHOST = $DBHOST

ELASTIC_HOST=$(php -r "\$config=require('config/local.php'); echo \$config['elastic_search']['host'];")
echo ELASTIC_HOST = $ELASTIC_HOST

INDEXES=( "address" "application" "busreg" "case" "irfo" "licence" "operator" "person" "pi_hearing" "psv_disc" "publication" "recipient" "user" "vehicle_current" "vehicle_removed" )
#INDEXES=( "irfo" )
echo Working on indexes: ${INDEXES[@]}





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
    sleep 300

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





# check index stats, ie are the record counts similar, Difficult to do this in bash





echo ==================================================
echo $(date)
echo =========== CREATE SCHEDULED RIVERS ==============
reindexEvery=15
for index in "${INDEXES[@]}"
do
    startMinute=$(( ( RANDOM % $reindexEvery ) ))
    echo $index
    cd ../$index
    source ../utilities/createIndexRiver.sh $DBHOST $DBNAME $DBUSER $DBPASSWORD $index $newVersion $startMinute/$reindexEvery
done





if [ "$promoteNewIndex" != "true" ]; then
    echo NOT promoting new index
exit
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
