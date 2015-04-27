#!/bin/bash

db=$1
username=$2
password=$3

value=$(<busreg.sql)

echo $value

new_val=${value//\'/\\\"}
new_val2=${new_val//\n/ }
new_val3=${new_val2// */ }



echo $new_val2

