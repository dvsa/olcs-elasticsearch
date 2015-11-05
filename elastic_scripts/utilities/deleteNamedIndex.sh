#!/bin/bash

index=$1
version=${2:-1}  
curl -XDELETE 'localhost:9200/'$index'_v'$version''
