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
    exit;
}

INDEXES=( "address" "application" "busreg" "case" "irfo" "licence" "operator" "person" "pi_hearing" "psv_disc" "publication" "recipient" "user" "vehicle_current" "vehicle_removed" )

while getopts ":e:h:u:p:m:d:r:n:ils" opt; do
  case $opt in
    e)
        ELASTIC_HOST=$OPTARG
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


echo ==================================================
echo $(date)


echo ELASTIC_HOST = $ELASTIC_HOST

echo
echo ABOUT TO DELETE ALL RIVERS AND INDEXES

echo
read -p "Press [Enter] key to start..."
echo





echo ==================================================
echo $(date)
echo ========== DELETE ALL RIVERS ===============
cd ../utilities
for index in "${INDEXES[@]}"
do
    echo $index
    source deleteNamedRiver.sh $index
done



echo ==================================================
echo $(date)
echo ============= DELETING v1 INDEXES ===============
cd ../utilities
for index in "${INDEXES[@]}"
do
    echo $index
    source deleteNamedIndex.sh $index 1
done



echo ==================================================
echo $(date)
echo ============= DELETING v2 INDEXES ===============
cd ../utilities
for index in "${INDEXES[@]}"
do
    echo $index
    source deleteNamedIndex.sh $index 2
done




echo ==================== DONE ========================
echo $(date)
