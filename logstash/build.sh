#!/bin/bash

typeset -i errorcount
let errorcount=0

usage() {
    if [ -n "$1" ]; then
        echo;
        echo "Error : $1"
    fi

    echo;
    echo "Usage:  build.sh [options]"
    echo;
    echo "        -c <file>     : bash file containing config"
    echo "        -f <file>     : File to generate eg /etc/logstash/populate_indices.conf"
    echo "        -l            : Promote new index, assign it the alias and delete the old index"
    echo "        -d <seconds>  : Number of seconds delay when checking if rivers are complete"
    echo "        -i <index>    : Only rebuild one index"
    echo "        -p            : Rebuild indexes in parallel rather than sequentially"
    echo
    exit;
}

blankline() {
    if [ "$logfile" == "" ]; then
        echo -e "\n"
    else
        echo -e "\n" >> $logfile
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
newVersion=$(date +%Y%m%d%H%M%S) #timestamp
CONF_FILE=populate_indices.conf
processInParallel=false

while getopts "c:f:d:n:i:lp" opt; do
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
    INDEXES=( "irfo" "busreg" "case" "application" "user" "licence" "psv_disc" "address" "person" "vehicle_current" "publication"  "vehicle_removed" )
fi


LOCKFILE=$(readlink -m build.lock)
if [ -f $LOCKFILE ]; then
    doubleline
    log "WARNING:It appears this script is already running, if you believe this is incorrect you "
    log "        can manually delete the lock file '$LOCKFILE'"
    doubleline
    exit;
fi
touch $LOCKFILE

doubleline
log "INFO:   RUN CONFIGURATION"
blankline
log "INFO:   Config File:           $CONF_FILE"
log "INFO:   Working on indexes:    ${INDEXES[*]}"
log "INFO:   Delay:                 $delay seconds"
log "INFO:   Reindex:               $reindex minutes"
log "INFO:   New version:           $newVersion"
blankline

singleline
log "INFO:   INDEX STATS BEFORE"
blankline
curl -XGET -s "http://$ELASTIC_HOST:9200/_cat/indices" | sort

blankline

#BUILD ALL IN PARALLEL
if [ $processInParallel = true ]; then 
    # BEGINNING  OF OPERATIONS SPECIFIC TO THE BUILD IN PARALLEL OPTION
	
    for index in "${INDEXES[@]}"
    do
        singleline
        log "INFO:   DELETING MATCHING INDEXES WITHOUT AN ALIAS"
        blankline
     
        indexsWithoutAlias=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases | python ./py/indexWithoutAlias.py $index })
     
        if [ ! -z $indexsWithoutAlias ]; then
            log "INFO:   Indexes without aliases : $indexsWithoutAlias"
            response=$(curl -XDELETE -s $ELASTIC_HOST:9200/$indexsWithoutAlias)
    
            if [[ "$response" != "{\"acknowledged\":true}" ]]; then
                log "ERROR:  Matching indexes without aliases were not deleted: [${indexsWithoutAlias}] - error code [${response}]."
                let $errorcount = $errorcount + 1
            else
                log "INFO:   Matching indexes without aliases were deleted - $indexsWithoutAlias"
            fi
        else
            log "INFO:   No matching indexes found without aliases"
        fi
    done
	
	log "INFO:   CREATING NEW INDEXES"
    singleline
    log "INFO:   Stopping logstash"
    /etc/init.d/logstash stop

    # IMPROVEMENT REQD: The outcome of the logstash service stop command should be checked and reported

    for index in "${INDEXES[@]}"
    do
    
        log "INFO:   Updating config file for index $index and new version - ${index}_v${newVersion}"

        sed "s/index => \"${index}_v[0-9]*\"/index => \"${index}_v${newVersion}\"/" -i $CONF_FILE

        log "INFO:   Removing last run file - /etc/logstash/lastrun/${index}.lastrun"
        rm -f /etc/logstash/lastrun/${index}.lastrun
		
        # IMPROVEMENT REQD: The outcome of the rm command should be checked and reported
		# Note that the lastrun file may not be present
    done
	
    log "INFO:   Starting logstash"
    /etc/init.d/logstash start

    # IMPROVEMENT REQD: The outcome of the logstash service start command should be checked and reported
		
    # END OF OPERATIONS SPECIFIC TO THE BUILD IN PARALLEL OPTION
fi

for index in "${INDEXES[@]}"
do
    if [ $processInParallel != true ]; then 
        # BEGINNING OF OPERATIONS SPECIFIC TO THE BUILD SEQUENTIALLY OPTION
        singleline
        log "INFO:   DELETING MATCHING INDEXES WITHOUT AN ALIAS"
        blankline
     
        indexsWithoutAlias=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases | python ./py/indexWithoutAlias.py $index })
     
        if [ ! -z $indexsWithoutAlias ]; then
            log "INFO:   Indexes without aliases : $indexsWithoutAlias"
            response=$(curl -XDELETE -s $ELASTIC_HOST:9200/$indexsWithoutAlias)
    
            if [[ "$response" != "{\"acknowledged\":true}" ]]; then
                log "ERROR:  Matching indexes without aliases were not deleted: [${indexsWithoutAlias}] - error code [${response}]."
                let $errorcount = $errorcount + 1
            else
                log "INFO:   Matching indexes without aliases were deleted - $indexsWithoutAlias"
            fi
        else
            log "INFO:   No matching indexes found without aliases"
        fi

        singleline
        log "INFO:   CREATING NEW INDEX : $index"
        log "INFO:   Updating config file for index $index and new version - ${index}_v${newVersion}"
        log "INFO:   Stopping logstash"
        /etc/init.d/logstash stop

        sed "s/index => \"${index}_v[0-9]*\"/index => \"${index}_v${newVersion}\"/" -i $CONF_FILE

        log "INFO:   Removing last run file - /etc/logstash/lastrun/${index}.lastrun"
        rm -f /etc/logstash/lastrun/${index}.lastrun

        # IMPROVEMENT REQD: The outcome of the rm command should be checked and reported
		# Note that the lastrun file may not be present
    
        log "INFO:   Starting logstash"
        /etc/init.d/logstash start
    
	    # END OF OPERATIONS SPECIFIC TO THE BUILD SEQUENTIALLY OPTION
    fi

    log "INFO:   Populate Index $index"

    lastSize=0
    while true; do
        # wait X seconds before checking
        sleep $delay

        size=$(curl -XGET -s "http://$ELASTIC_HOST:9200/${index}_v${newVersion}/_stats" | python ./py/getIndexSize.py)
        log "INFO:   ${index}_v${newVersion} size = $size"
        if [ "$size" -lt 10 ]; then
            continue
        fi

        if [ "$lastSize" == "$size" ]; then
            log "INFO:   Document count of [${index}] index has not changed in the last ${delay} secs, it may be fully populated."
            if [ -f /etc/logstash/lastrun/${index}.lastrun ]; then
				log "INFO:   Lastrun file exists, so assuming index is fully populated - $index"
            	break;
			fi
        fi

        lastSize=$size
    done

    if [ "$promoteNewIndex" != "true" ]; then
        log "INFO:   Alias is not being moved to the new index - $index"
    else
        log "INFO:   Moving the alias to the new index - $index"
        modifyBody=$(curl -s -XGET $ELASTIC_HOST:9200/_aliases?pretty=1 | python ./py/modifyAliases.py $newVersion $index)
        response=$(curl -XPOST -s $ELASTIC_HOST':9200/_aliases' -d "$modifyBody")
        if [[ $response != "{\"acknowledged\":true}" ]]; then
            log "ERROR:  Alias not moved for $index index - error code is [${response}]."
            let $errorcount = $errorcount + 1
        else
            log "INFO:   Successfully moved the alias to the new index - $index"
        fi
    fi
	
	log "INFO:   Enable replicas for [${index}] index."
    curl -s -XPUT "http://$ELASTIC_HOST:9200/${index}/_settings" -H 'Content-Type: application/json' -d '{"index": {"number_of_replicas": 1}}'

    # IMPROVEMENT REQD: The outcome of the curl command should be checked and reported


    blankline
done

log "INFO:   Enable ALL replicas"
curl -s -XPUT "http://$ELASTIC_HOST:9200/_settings" -H 'Content-Type: application/json' -d '{"index": {"number_of_replicas": 1}}'
# IMPROVEMENT REQD: The outcome of the curl command should be checked and reported

singleline
log "INFO:   INDEX STATS AFTER"
blankline

curl -XGET -s "http://$ELASTIC_HOST:9200/_cat/indices" | sort
blankline

log "INFO:   Removing lock file $LOCKFILE"
blankline

rm -f $LOCKFILE
ret=$?
if [[ $ret != 0 ]]; then
            log "ERROR:  Failed to remove the Process Lock File: [${LOCKFILE}] - error code ]${ret}]."
            let $errorcount = $errorcount + 1
else
            log "INFO:   Process Lock File: [${LOCKFILE}] has been removed."
fi

if [[ $errorcount != 0 ]]; then
    log "ERROR:  All processing completed but [$errorcount] errors were detected - please check logs"
    blankline
    doubleline
    exit $errorcount
else
    log "INFO:   All processing completed with no errors"
    blankline
    doubleline
    exit 0
fi

