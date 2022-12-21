#!/usr/bin/env bash

echo $PATH

pidfile=/tmp/onboard.pid

if test -f "$pidfile"; then
    echo "keyboard is running"
    pid=$(<"$pidfile")
    rm -f "$pidfile"
    kill -9 "$pid"
else
    echo "starting keyboard"
    onboard &
    pid=$!
    echo $pid > "$pidfile"
fi

