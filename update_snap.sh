#!/bin/bash

/usr/local/esa-snap/bin/snap --nosplash --nogui --modules --update-all 2>&1 | while read -r line; do
    echo "$line"
     if [ "$line" = "updates=0" ]; then
        sleep 2
        if pgrep -f "snap/jre/bin/java" > /dev/null; then
            pkill -TERM -f "snap/jre/bin/java"
        fi
    fi
done