#!/bin/bash

typeset -i errorcount
let errorcount=0

usage() {
    if [ -n "$1" ]; then
        echo;
        echo "Error: $1"
    fi

    echo;
    echo "Usage:  build.sh [options]"
    echo;
    echo "        -c <file>     : bash file containing config"
    echo "        -f <file>     : File to generate eg /etc/logstash/populate_indices.conf"
    echo "        -l            : Promote new index, assign it the alias and delete the old index"
    echo "        -d <seconds>  : Number of seconds delay when checking if rivers are complete"
    echo "        -i <index>    : Rebuild named index - multiple '-i <name>' clauses may be specified"
    echo "        -p            : Rebuild indexes in parallel rather than sequentially"
    echo "        -s            : Suppress syslog output."
    echo
    exit;
}

blankline() {
    if [ "$logfile" == "" ]; then
        echo -e ""
    else
        echo -e "" >> $logfile
    fi
}

singleline() {
    if [ "$logfile" == "" ]; then
        echo -e "----------------------------------------------------------------------------------------------------"
    else
        echo -e "----------------------------------------------------------------------------------------------------" >> $logfile
    fi
}

doubleline() {
    if [ "$logfile" == "" ]; then
        echo -e "===================================================================================================="
    else
        echo -e "====================================================================================================" >> $logfile
    fi
}

logInfo() {
    if [ "$logfile" == "" ]; then
        echo -e $(date) "INFO:   " $1
    else
        echo $(date) "INFO:   " >> $logfile
        echo -e $1 >> $logfile
    fi

    if [ "$2" == "true" ]; then
         logger -i -p user.info -t ESbuild -- "INFO:   $1"
    fi
}

logError() {
    if [ "$logfile" == "" ]; then
        echo -e $(date) "ERROR:  " $1
    else
        echo $(date) "ERROR:  " >> $logfile
        echo -e $1 >> $logfile
    fi
    
    if [ "$2" == "true" ]; then
        logger -i -p user.notice -t ESbuild -- "ERROR:  $1"
    fi
}

logWarning() {
    if [ "$logfile" == "" ]; then
        echo -e $(date) "WARNING:" $1
    else
        echo $(date) "WARNING:" >> $logfile
        echo -e $1 >> $logfile
    fi
    
    if [ "$2" == "true" ]; then
        logger -i -p user.warning -t ESbuild -- "WARNING:$1"
    fi
}



delay=70 # seconds
newVersion=$(date +%Y%m%d%H%M%S) #timestamp
CONF_FILE=populate_indices.conf
processInParallel=false
syslogEnabled=true
promoteNewIndex=false

while getopts "c:f:d:n:i:lps" opt; do
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
    p)
        processInParallel=true
      ;;
    s)
        syslogEnabled=false
      ;;
    d)
        delay=$OPTARG
      ;;
    n)
        newVersion=$OPTARG
      ;;
    i)
        INDEXES=(${INDEXES[@]} "${OPTARG}")
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
    INDEXES=( "irfo" "busreg" "case" "application" "user" "licence" "psv_disc" "address" "person" "vehicle_current" "publication"  "vehicle_removed" )
fi


LOCKFILE=$(readlink -m build.lock)
if [ -f $LOCKFILE ]; then
    doubleline
    logWarning "This script may already be running, if this is incorrect delete the lock file ${LOCKFILE}." ${syslogEnabled}
    doubleline
    exit;
fi
touch $LOCKFILE

doubleline
logInfo "ES REBUILD WITH THE FOLLOWING CONFIGURATION" ${syslogEnabled}
blankline
logInfo "ES Rebuild Config File:     ${CONF_FILE}" ${syslogEnabled}
logInfo "ES Rebuild Target indexes:  ${INDEXES[*]}" ${syslogEnabled}
logInfo "ES Rebuild Delay:           ${delay}" ${syslogEnabled}
logInfo "ES Rebuild New version:     ${newVersion}" ${syslogEnabled}
logInfo "ES Rebuild Syslog Enabled:  ${syslogEnabled}" ${syslogEnabled}
logInfo "ES Rebuild Promote Index:   ${promoteNewIndex}" ${syslogEnabled}
logInfo "ES Rebuild Paralellised:    ${processInParallel}" ${syslogEnabled}

blankline

singleline
logInfo "INDEX STATS BEFORE" ${syslogEnabled}
blankline

for index in "${INDEXES[@]}"; do curl -ss http://$ELASTIC_HOST:9200/_cat/indices?pretty | grep $index | sort ; done
#curl -XGET -s "http://$ELASTIC_HOST:9200/_cat/indices" | sort  

if [ "${syslogEnabled}" == "true" ]; then
    for index in "${INDEXES[@]}"; do curl -ss http://$ELASTIC_HOST:9200/_cat/indices?pretty | grep $index | sort ; done | sort | sed "s/^/INFO:   /" | while read oneLine; do logger -i -p user.warning -t ESbuild -- "$oneLine"; done
#    curl -XGET -s "http://$ELASTIC_HOST:9200/_cat/indices" | sort | sed "s/^/INFO:   /" | while read oneLine; do logger -i -p user.warning -t ESbuild -- "$oneLine"; done
fi

blankline

#BUILD ALL IN PARALLEL
if [ $processInParallel = true ]; then 
    # BEGINNING  OF OPERATIONS SPECIFIC TO THE BUILD IN PARALLEL OPTION
    
    logInfo "DELETING MATCHING INDEXES WITHOUT AN ALIAS." ${syslogEnabled}
    blankline

    for index in "${INDEXES[@]}"
    do
        singleline
        logInfo "Deleting indexes matching [${index}] which have no alias." ${syslogEnabled}
     
        indexsWithoutAlias=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases | python ./py/indexWithoutAlias.py $index })
     
        if [ ! -z $indexsWithoutAlias ]; then
            logInfo "Matching indexes without aliases are [${indexsWithoutAlias}]." ${syslogEnabled}
            response=$(curl -XDELETE -s $ELASTIC_HOST:9200/$indexsWithoutAlias)
    
            if [[ "$response" != "{\"acknowledged\":true}" ]]; then
                logError "One or more matching indexes without an alias was not deleted: [${indexsWithoutAlias}] - error code [${response}]." ${syslogEnabled}
                let errorcount = $errorcount + 1
            else
                logInfo "The following matching indexes without aliases were deleted: [${indexsWithoutAlias}]." ${syslogEnabled}
            fi
        else
            logInfo "No indexes matching [${index}] were found without aliases" ${syslogEnabled}
        fi
    done
    
    singleline
    logInfo "CREATING NEW INDEXES" ${syslogEnabled}
    blankline

    logInfo "Stopping Logstash service prior to config file updates." ${syslogEnabled}
    response=$(/etc/init.d/logstash stop)
    ret=$?
    if [[ $ret != 0 ]]; then
        let errorcount = $errorcount + 1
        logError "Failed to stop the Logstash service [${response}] - error code [${ret}]." ${syslogEnabled}
        logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
        blankline
        doubleline
        exit $errorcount
    else
        logInfo "[${response}]." ${syslogEnabled}
        logInfo "Successfully stopped the Logstash service." ${syslogEnabled}
        logInfo "Successfully stopped the Logstash service [${response}]." ${syslogEnabled}
    fi

    for index in "${INDEXES[@]}"
    do
    
        logInfo "Updating config file for [${index}] index and new version [${index}_v${newVersion}]." ${syslogEnabled}

        sed "s/index => \"${index}_v[0-9]*\"/index => \"${index}_v${newVersion}\"/" -i $CONF_FILE

        logInfo "Removing last run file [/etc/logstash/lastrun/${index}.lastrun]." ${syslogEnabled}
        # Note that the lastrun file may not be present
        response=$(rm -f /etc/logstash/lastrun/${index}.lastrun)
        ret=$?
        if [[  -f /etc/logstash/lastrun/${index}.lastrun ]]; then
            let errorcount = $errorcount + 1
            logError "Failed to remove last run file [/etc/logstash/lastrun/${index}.lastrun] - error code [${ret}]." ${syslogEnabled}
            logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
            blankline
            doubleline
            exit $errorcount
        else
            logInfo "Successfully removed last run file [/etc/logstash/lastrun/${index}.lastrun]." ${syslogEnabled}
        fi
    done
    
    logInfo "Starting logstash" ${syslogEnabled}
    logInfo "Starting Logstash service." ${syslogEnabled}
    response=$(/etc/init.d/logstash start)
    ret=$?
    if [[ $ret != 0 ]]; then
        let errorcount = $errorcount + 1
        logError "Failed to start the Logstash service [${response}] - error code [${ret}]." ${syslogEnabled}
        logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
        blankline
        doubleline
        exit $errorcount
    else
        logInfo "Successfully started the Logstash service [${response}]." ${syslogEnabled}
    fi

    # END OF OPERATIONS SPECIFIC TO THE BUILD IN PARALLEL OPTION
fi

for index in "${INDEXES[@]}"
do
    if [ $processInParallel != true ]; then 
        # BEGINNING OF OPERATIONS SPECIFIC TO THE BUILD SEQUENTIALLY OPTION
        singleline
        logInfo "DELETING MATCHING INDEXES WITHOUT AN ALIAS" ${syslogEnabled}
        blankline
     
        indexsWithoutAlias=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases | python ./py/indexWithoutAlias.py $index })
     
        if [ ! -z $indexsWithoutAlias ]; then
            logInfo "Matching indexes without aliases are [${indexsWithoutAlias}]." ${syslogEnabled}
            response=$(curl -XDELETE -s $ELASTIC_HOST:9200/$indexsWithoutAlias)
    
            if [[ "$response" != "{\"acknowledged\":true}" ]]; then
                logError "One or more matching indexes without an alias was not deleted: [${indexsWithoutAlias}] - error code [${response}]." ${syslogEnabled}
                let errorcount = $errorcount + 1
            else
                logInfo "The following matching indexes without aliases were deleted: [${indexsWithoutAlias}]." ${syslogEnabled}
            fi
        else
            logInfo "No indexes matching [${index}] were found without aliases" ${syslogEnabled}
        fi

        blankline
        singleline
        logInfo "CREATING NEW INDEX [${index}]" ${syslogEnabled}
        blankline
        logInfo "Updating config file for [${index}] index and new version [${index}_v${newVersion}]." ${syslogEnabled}
        logInfo "Stopping Logstash service prior to config file updates." ${syslogEnabled}
        response=$(/etc/init.d/logstash stop)
        ret=$?
        if [[ $ret != 0 ]]; then
            let errorcount = $errorcount + 1
            logError "Failed to stop the Logstash service [${response}] - error code [${ret}]." ${syslogEnabled}
            logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
            blankline
            doubleline
            exit $errorcount
        else
            logInfo "[${response}]." ${syslogEnabled}
            logInfo "Successfully stopped the Logstash service." ${syslogEnabled}
            logInfo "Successfully stopped the Logstash service [${response}]." ${syslogEnabled}
        fi

        sed "s/index => \"${index}_v[0-9]*\"/index => \"${index}_v${newVersion}\"/" -i $CONF_FILE

        logInfo "Removing last run file [/etc/logstash/lastrun/${index}.lastrun]." ${syslogEnabled}
        # Note that the lastrun file may not be present
        response=$(rm -f /etc/logstash/lastrun/${index}.lastrun)
        ret=$?
        if [[  -f /etc/logstash/lastrun/${index}.lastrun ]]; then
            let errorcount = $errorcount + 1
            logError "Failed to remove last run file [/etc/logstash/lastrun/${index}.lastrun] - error code [${ret}]." ${syslogEnabled}
            logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
            blankline
            doubleline
            exit $errorcount
        else
            logInfo "Successfully removed last run file [/etc/logstash/lastrun/${index}.lastrun]." ${syslogEnabled}
        fi

        logInfo "Starting Logstash service." ${syslogEnabled}
        response=$(/etc/init.d/logstash start)
        ret=$?
        if [[ $ret != 0 ]]; then
            let errorcount = $errorcount + 1
            logError "Failed to start the Logstash service [${response}] - error code [${ret}]." ${syslogEnabled}
            logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
            blankline
            doubleline
            exit $errorcount
        else
            logInfo "Successfully started the Logstash service [${response}]." ${syslogEnabled}
        fi
    
        # END OF OPERATIONS SPECIFIC TO THE BUILD SEQUENTIALLY OPTION
    fi

    logInfo "Populate Index [${index}]." ${syslogEnabled}

    lastSize=0
    while true; do
        # wait X seconds before checking
        sleep $delay

        size=$(curl -XGET -s "http://$ELASTIC_HOST:9200/${index}_v${newVersion}/_stats" | python ./py/getIndexSize.py)
        logInfo "Loading data to [${index}_v${newVersion}] document count is $size" ${syslogEnabled}
        if [ "$size" -lt 10 ]; then
            continue
        fi

        if [ "$lastSize" == "$size" ]; then
            logInfo "Document count of [${index}_v${newVersion}] index has not changed in the last ${delay} secs, it may be fully populated." ${syslogEnabled}
            if [ -f /etc/logstash/lastrun/${index}.lastrun ]; then
                logInfo "Lastrun file exists, so assuming [${index}_v${newVersion}] is fully populated." ${syslogEnabled}
                break;
            fi
        fi

        lastSize=$size
    done

    if [ "$promoteNewIndex" != "true" ]; then
        logInfo "Alias [${index}] is not being moved to the new index [${index}_v${newVersion}]." ${syslogEnabled}
    else
        logInfo "Moving the alias [${index}] to the new index [${index}_v${newVersion}]." ${syslogEnabled}
        modifyBody=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases?pretty=1 | python ./py/modifyAliases.py $newVersion $index)
        response=$(curl -XPOST -s $ELASTIC_HOST':9200/_aliases' -d "$modifyBody")
        if [[ "${response}" != "{\"acknowledged\":true}" ]]; then
            logError "Alias [${index}] not moved to [${index}_v${newVersion}] - error code is [${response}]." ${syslogEnabled}
            let errorcount = $errorcount + 1
        else
            logInfo "Successfully moved alias [${index}] to the new index [${index}_v${newVersion}]." ${syslogEnabled}
        fi
    fi
    
    logInfo "Enable replicas for [${index}_v${newVersion}] index." ${syslogEnabled}
    response=$(curl -s -XPUT "http://$ELASTIC_HOST:9200/${index}_v${newVersion}/_settings" -H 'Content-Type: application/json' -d '{"index": {"number_of_replicas": 1}}')
    if [[ ${response} != "{\"acknowledged\":true}" ]]; then
        logError "Failed to enable replicas for [${index}_v${newVersion}] - error code is [${response}]." ${syslogEnabled}
        let errorcount = $errorcount + 1
    else
        logInfo "Successfully configured replicas for [${index}_v${newVersion}] index." ${syslogEnabled}
    fi

    blankline
done

logInfo "Enable ALL replicas" ${syslogEnabled}
response=$(curl -s -XPUT "http://$ELASTIC_HOST:9200/_settings" -H 'Content-Type: application/json' -d '{"index": {"number_of_replicas": 1}}')
if [[ $response != "{\"acknowledged\":true}" ]]; then
    logError "Failed to configure replicas for all indexes - error code is [${response}]." ${syslogEnabled}
    let errorcount = $errorcount + 1
else
    logInfo "Successfully configured replicas for all indexes." ${syslogEnabled}
fi

blankline
singleline
logInfo "INDEX STATS AFTER" ${syslogEnabled}
blankline

curl -XGET -s "http://$ELASTIC_HOST:9200/_cat/indices" | sort  

if [ "${syslogEnabled}" == "true" ]; then
    curl -XGET -s "http://$ELASTIC_HOST:9200/_cat/indices" | sort | sed "s/^/INFO:   /" | while read oneLine; do logger -i -p user.warning -t ESbuild -- "$oneLine"; done
fi

blankline
logInfo "Removing lock file [${LOCKFILE}]." ${syslogEnabled}

rm -f $LOCKFILE
ret=$?
if [[ $ret != 0 ]]; then
    logError "Failed to remove the Process Lock File: [${LOCKFILE}] - error code [${ret}]." ${syslogEnabled}
    let errorcount = $errorcount + 1
else
    logInfo "Lock File: [${LOCKFILE}] has been removed." ${syslogEnabled}
fi

if [[ $errorcount != 0 ]]; then
    logError "All processing completed but [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
    blankline
    doubleline
    exit $errorcount
else
    logInfo "All processing completed with no errors." ${syslogEnabled}
    blankline
    doubleline
    exit 0
fi


