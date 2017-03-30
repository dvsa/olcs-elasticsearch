#!/bin/bash

usage() {
    if [ -n "$1" ]; then
        echo;
        echo Error : $1
    fi

    echo;
    echo Usage: generate-conf.sh [options];
    echo;
    echo "-f <file>       : File to generate eg /etc/logstash/populate_indices.conf";
    echo "-c <file>       : bash file containing config";
    echo "-e <hostname>   : Elasticsearch server hostname";
    echo "-h <dbname>     : Database host";
    echo "-u <dbuser>     : Database user";
    echo "-p <dbpassword> : Database password";
    echo '-m <dbname>     : Database name'
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
}

CONF_FILE=populate_indices.conf

while getopts "f:c:e:h:u:p:m:" opt; do
  case $opt in
    f)
        if [ ! -f $OPTARG ]; then
          usage "Conf file doesn't exist";
        fi
        CONF_FILE=$OPTARG
      ;;
    c)
        if [ ! -f $OPTARG ]; then
          usage "Config file $OPTARG doesn't exist";
        fi
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

newVersion=$(date +%s) #timestamp

log "Replace placeholders in logstash config file"
BASEDIR=$(dirname $(readlink -m $0))
cp $BASEDIR/populate_indices.conf.dist $CONF_FILE
sed "s/<DB_HOST>/$DBHOST/" -i $CONF_FILE
sed "s/<DB_NAME>/$DBNAME/" -i $CONF_FILE
sed "s/<DB_USER>/$DBUSER/" -i $CONF_FILE
sed "s/<DB_PASSWORD>/$DBPASSWORD/" -i $CONF_FILE
sed "s/<ES_HOST>/$ELASTIC_HOST/" -i $CONF_FILE
sed "s/<INDEX_VERSION>/$newVersion/" -i $CONF_FILE
sed "s#<LOGSTASH_PATH>#$LOGSTASH_PATH#" -i $CONF_FILE
sed "s#<BASEDIR>#$BASEDIR#" -i $CONF_FILE

log "Done"