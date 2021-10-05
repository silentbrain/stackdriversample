#!/bin/bash 

while read INSTANCE_NAME ZONE
do 
    echo ${INSTANCE_NAME} ${ZONE}
done < prd-sc-list.csv