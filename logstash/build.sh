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

function stopService()
{
    typeset -i retryCount=0
    typeset -i sleepTime=20
    typeset -i retryLimit=6

    serviceName="$1"

    if [[ $2 =~ ^[0-9]+$ ]] ; then
        let sleepTime=$((10#$2))
    fi

    if [[ $3 =~ ^[0-9]+$ ]] ; then
        let retryLimit=$((10#$3))
    fi

    while true
    do
        response=$(/usr/bin/systemctl --quiet status ${serviceName})
        ret=$?

        if [[ $ret == 3 ]]; then
            logInfo "The [${serviceName}] service is already stopped." ${syslogEnabled}
            return 0
        else
            logInfo "Stopping [${serviceName}] service." ${syslogEnabled}
            response=$(/usr/bin/systemctl --quiet --job-mode=fail stop ${serviceName})
            ret=$?

            if [[ $ret != 0 ]]; then
                let retryCount=$((retryCount + 1))
                logInfo "Failed to stop the [${serviceName}] service on attempt [${retryCount}] - error code [${ret}]." ${syslogEnabled}

                if (( ${retryCount} < ${retryLimit} )); then
                    logInfo "Backing off for [${sleepTime}] seconds." ${syslogEnabled}
                    sleep ${sleepTime}
                else
                    logError "Failed to stop the [${serviceName}] service after [${retryCount}] attempts." ${syslogEnabled}
                    return 1
                fi
            else
                logInfo "Successfully stopped the [${serviceName}] service." ${syslogEnabled}
                return 0
            fi
        fi
        blankline
    done
}

function startService()
{
    typeset -i retryCount=0
    typeset -i sleepTime=20
    typeset -i retryLimit=6
    
    serviceName="$1"

    if [[ $2 =~ ^[0-9]+$ ]] ; then
        let sleepTime=$((10#$2))
    fi

    if [[ $3 =~ ^[0-9]+$ ]] ; then
        let retryLimit=$((10#$3))
    fi

    while true
    do
        response=$(/usr/bin/systemctl --quiet status ${serviceName})
        ret=$?

        if [[ $ret == 0 ]]; then
            logInfo "The [${serviceName}] service is already started." ${syslogEnabled}
            return 0
        else
            logInfo "Starting [${serviceName}] service." ${syslogEnabled}
            response=$(/usr/bin/systemctl --quiet --job-mode=fail start ${serviceName})
            ret=$?

            if [[ $ret != 0 ]]; then
                let retryCount=$((retryCount + 1))
                logInfo "Failed to start the [${serviceName}] service on attempt [${retryCount}] - error code [${ret}]." ${syslogEnabled}
    	
                if (( ${retryCount} < ${retryLimit} )); then
                    logInfo "Backing off for [${sleepTime}] seconds." ${syslogEnabled}
    		    sleep ${sleepTime}
                else
                    logError "Failed to start the [${serviceName}] service after [${retryCount}] attempts." ${syslogEnabled}
                    return 1
                fi
            else
                logInfo "Successfully started the [${serviceName}] service." ${syslogEnabled}
                return 0
            fi
        fi
        blankline
    done
}

function removeLastrun()
{
    logInfo "Removing last run file [${1}." ${2}
    # Note that the lastrun file may not be present
    response=$(rm -f "${1}")
    ret=$?
    if [[  -f ${1} ]]; then
        logError "Failed to remove last run file [${1}] - error code [${ret}]." ${2}
        return 1
    else
        logInfo "Successfully removed last run file [${1}]." ${2}
    fi

    return 0
}

function removeLockfile()
{
    logInfo "Removing lock file [${1}]." ${syslogEnabled}

    response=$(rm -f "${1}")
    ret=$?
    if [[  -f ${1} ]]; then
        logError "Failed to remove the Process Lock File: [${1}] - error code [${ret}]." ${2}
        return 1
    else
        logInfo "Lock File: [${1}] has been removed." ${2}
        return 0
    fi
}

delay=70 # seconds
newVersion=$(date +%Y%m%d%H%M%S) #timestamp
CONF_FILE=populate_indices.conf
processInParallel=false
syslogEnabled=true
promoteNewIndex=false

#
# Determine if this is the first run after the SEARCHDATA instance start, 
# in which case, no lastrun files will be present in /etc/logstash/lastrun
#

lastrunCount=$(ls /etc/logstash/lastrun | grep ".*\.lastrun" | wc -l )
if [[ "$lastrunCount" == "0" ]]; then
    processInParallel=true
fi

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


lockFile=$(readlink -m build.lock)
if [ -f $lockFile ]; then
    doubleline
    logWarning "This script may already be running, if this is incorrect delete the lock file ${lockFile}." ${syslogEnabled}
    doubleline
    exit;
fi
touch $lockFile

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

for index in "${INDEXES[@]}"; do curl -XGET -ss http://$ELASTIC_HOST:9200/_cat/indices?pretty | grep $index | sort ; done
if [ "${syslogEnabled}" == "true" ]; then
    for index in "${INDEXES[@]}"; do curl -XGET -ss http://$ELASTIC_HOST:9200/_cat/indices?pretty | grep $index | sort ; done | sed "s/^/INFO:   /" | while read oneLine; do logger -i -p user.warning -t ESbuild -- "$oneLine"; done
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
     
        indexsWithoutAlias=$(curl -s -XGET http://$ELASTIC_HOST:9200/_aliases | python2.7 ./py/indexWithoutAlias.py $index })
     
        if [ ! -z $indexsWithoutAlias ]; then
            logInfo "Matching indexes without aliases are [${indexsWithoutAlias}]." ${syslogEnabled}
            response=$(curl -XDELETE -s http://$ELASTIC_HOST:9200/$indexsWithoutAlias)
    
            if [[ "$response" != "{\"acknowledged\":true}" ]]; then
                logError "One or more matching indexes without an alias was not deleted: [${indexsWithoutAlias}] - error code [${response}]." ${syslogEnabled}
                let errorcount=$((errorcount + 1))
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
    stopService "logstash" 30 6
    ret=$?
    if [[ $ret != 0 ]]; then
        let errorcount=$((errorcount + 1))
        removeLockfile "${lockFile}" ${syslogEnabled}
        if [[ $? != 0 ]]; then
            let errorcount=$((errorcount + 1))
        fi
        
        logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
        blankline
        doubleline
        exit $errorcount
    fi

    for index in "${INDEXES[@]}"
    do
    
        logInfo "Updating config file for [${index}] index and new version [${index}_v${newVersion}]." ${syslogEnabled}

        sed "s/index => \"${index}_v[0-9]*\"/index => \"${index}_v${newVersion}\"/" -i $CONF_FILE

        removeLastrun "/etc/logstash/lastrun/${index}.lastrun"  ${syslogEnabled}
        if [[ $? != 0 ]]; then
            let errorcount=$((errorcount + 1))
            removeLockfile "${lockFile}" ${syslogEnabled}
            if [[ $? != 0 ]]; then
                let errorcount=$((errorcount + 1))
            fi
        
            logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
            blankline
            doubleline
            exit $errorcount
        fi
        
    done
    
    logInfo "Starting Logstash service after config file updates.." ${syslogEnabled}

    startService "logstash" 30 6 
    ret=$?
    if [[ $ret != 0 ]]; then
        let errorcount=$((errorcount + 1))
        removeLockfile "${lockFile}" ${syslogEnabled}
        if [[ $? != 0 ]]; then
            let errorcount=$((errorcount + 1))
        fi
        
        logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
        blankline
        doubleline
        exit $errorcount
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
     
        indexsWithoutAlias=$(curl -s -XGET http://$ELASTIC_HOST:9200/_aliases | python2.7 ./py/indexWithoutAlias.py $index })
     
        if [ ! -z $indexsWithoutAlias ]; then
            logInfo "Matching indexes without aliases are [${indexsWithoutAlias}]." ${syslogEnabled}
            response=$(curl -XDELETE -s http://$ELASTIC_HOST:9200/$indexsWithoutAlias)
    
            if [[ "$response" != "{\"acknowledged\":true}" ]]; then
                logError "One or more matching indexes without an alias were not deleted: [${indexsWithoutAlias}] - error code [${response}]." ${syslogEnabled}
                let errorcount=$((errorcount + 1))
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
        stopService "logstash" 30 6 
        ret=$?
        if [[ $ret != 0 ]]; then
            let errorcount=$((errorcount + 1))
            
            if [[ $? != 0 ]]; then
                let errorcount=$((errorcount + 1))
            fi
        
            logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
            blankline
            doubleline
            exit $errorcount
        fi

        sed "s/index => \"${index}_v[0-9]*\"/index => \"${index}_v${newVersion}\"/" -i $CONF_FILE

        removeLastrun "/etc/logstash/lastrun/${index}.lastrun"  ${syslogEnabled}
        if [[ $? != 0 ]]; then
            let errorcount=$((errorcount + 1))
            removeLockfile "${lockFile}" ${syslogEnabled}
            if [[ $? != 0 ]]; then
                let errorcount=$((errorcount + 1))
            fi
        
            logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
            blankline
            doubleline
            exit $errorcount
        fi
        
        logInfo "Starting Logstash service." ${syslogEnabled}
        startService "logstash" 30 6 
        ret=$?
        if [[ $ret != 0 ]]; then
            let errorcount=$((errorcount + 1))
            removeLockfile "${lockFile}" ${syslogEnabled}
            if [[ $? != 0 ]]; then
                let errorcount=$((errorcount + 1))
            fi
        
            logError "Processing aborted due to a fatal error - [${errorcount}] errors were detected - please check logs." ${syslogEnabled}
            blankline
            doubleline
            exit $errorcount
        fi
    
        # END OF OPERATIONS SPECIFIC TO THE BUILD SEQUENTIALLY OPTION
    fi

    logInfo "Populate Index [${index}]." ${syslogEnabled}

    lastSize=0
    while true; do
        # wait X seconds before checking
        sleep $delay

        size=$(curl -XGET -s "http://$ELASTIC_HOST:9200/${index}_v${newVersion}/_stats" | python2.7 ./py/getIndexSize.py)
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
        modifyBody=$(curl -s -XGET http://$ELASTIC_HOST:9200/_aliases?pretty | python2.7 ./py/modifyAliases.py $newVersion $index)
        response=$(curl -XPOST -s "http://$ELASTIC_HOST:9200/_aliases" -H 'Content-Type: application/json' -d "$modifyBody")
        if [[ "${response}" != "{\"acknowledged\":true}" ]]; then
            logError "Alias [${index}] not moved to [${index}_v${newVersion}] - error code is [${response}]." ${syslogEnabled}
            let errorcount=$((errorcount + 1))
        else
            logInfo "Successfully moved alias [${index}] to the new index [${index}_v${newVersion}]." ${syslogEnabled}
        fi
    fi
    
    logInfo "Enable replicas for [${index}_v${newVersion}] index." ${syslogEnabled}
    response=$(curl -s -XPUT "http://$ELASTIC_HOST:9200/${index}_v${newVersion}/_settings" -H 'Content-Type: application/json' -d '{"index": {"number_of_replicas": 1}}')
    if [[ ${response} != "{\"acknowledged\":true}" ]]; then
        logError "Failed to enable replicas for [${index}_v${newVersion}] - error code is [${response}]." ${syslogEnabled}
        let errorcount=$((errorcount + 1))
    else
        logInfo "Successfully configured replicas for [${index}_v${newVersion}] index." ${syslogEnabled}
    fi

    blankline
done

singleline
logInfo "INDEX STATS AFTER" ${syslogEnabled}
blankline

for index in "${INDEXES[@]}"; do curl -XGET -ss http://$ELASTIC_HOST:9200/_cat/indices?pretty | grep $index | sort ; done

if [ "${syslogEnabled}" == "true" ]; then
    for index in "${INDEXES[@]}"; do curl -XGET -ss http://$ELASTIC_HOST:9200/_cat/indices?pretty | grep $index | sort ; done | sed "s/^/INFO:   /" | while read oneLine; do logger -i -p user.warning -t ESbuild -- "$oneLine"; done
fi

blankline

removeLockfile "${lockFile}" ${syslogEnabled}
if [[ $? != 0 ]]; then
    let errorcount=$((errorcount + 1))
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
