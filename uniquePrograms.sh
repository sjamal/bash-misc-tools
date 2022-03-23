#!/bin/bash

ACTIVE_PROGS=$1
CURR_COURSES=$2

COURSES=$(tail -n+2 $CURR_COURSES | awk -F ',' '{print $1}' | tr "\\n" " ")

for COURSE in $COURSES; do 
        grep -q $COURSE $ACTIVE_PROGS
        if [[ $? -eq 0 ]]
        then 
            grep $COURSE $ACTIVE_PROGS | sed 's/$/ ,'"$COURSE"'/' >> ProgsWithCourseAssocs.csv
        fi
done

# END
