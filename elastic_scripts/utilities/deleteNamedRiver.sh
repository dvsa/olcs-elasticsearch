#!/bin/bash

river=$1
curl -XDELETE 'localhost:9200/_river/olcs_'$river'_river'
