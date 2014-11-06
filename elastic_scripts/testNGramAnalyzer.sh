#!/bin/bash

curl -XGET 'localhost:9200/_analyze?pretty=1&analyzer=standard' -d 'd.h.l.abcde.fghi.jkl.mnr.o'
