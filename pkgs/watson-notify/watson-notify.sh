#!/usr/bin/env bash
#
# Copyright © 2016 Yannick Loiseau <me@yloiseau.net>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
#
set -e
VERSION=0.2
if [ ! -z $WATSON_DIR ] ; then
    CONFIG_DIR=$WATSON_DIR
fi
WATSON_STATUS="python3 -m watson status"
NOTIFY="notify-send"
DISPLAY=:0
RUNTIME="${XDG_RUNTIME_HOME:-/run/user/$UID}/watson"
SNOOZE_FILE="$RUNTIME/snooze"

# Alert parameters: can be redefined in $WATSON_DIR/alert.
ALERT_TIME=7200 # 2 hours
ALERT_MESSAGE="Still working on %s?\nTime for a break or to run\n 'watson-notify --snooze'"
ALERT_NOTIF="-u low -t 5000"
QUESTION_MESSAGE="What are you doing?"
QUESTION_NOTIF="-u critical -t 10000"
SNOOZE_TIME="1 hour"

[ -f "$CONFIG_DIR/alert" ] && source "$CONFIG_DIR/alert"

export DISPLAY

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function usage {
    cat <<EOC
A notification for Watson <https://github.com/TailorDev/Watson>.

This script checks if you are working on a project with Watson and display a
notification when:
- you are working on the same project for more than $ALERT_TIME (seconds)
- you are not working on a project

The purpose is to remind you to start tracking your time, or to check if you
have forgotten to change the project (and remind you to take a break).

Usage:
0. Save this script somewhere (e.g. $HOME/bin)
1. Customize the alert message and time. See '$0 -c'
1a. Customize DISPLAY if needed
2. Set a cron task to run the script. E.g. (every 5min)

    */5 *  *   *   *     $0

Options:
  -h|--help          display this help
  -v|--version       display the version
  -c|--config        display the current configuration
  -V|--status        display the current status
  -a|--activate      activate the notification
  -s|--snooze UNTIL  disable the notification until the given date
                       (UNTIL is a 'date' compatible expression, default to ${SNOOZE_TIME})

Files:
  $CONFIG_DIR/alert  contains custom options
EOC
}

function config {
    cat <<EOC
# $CONFIG_DIR/alert
# watson-notify configuration.

## Alert

# When to say to stop the task (in seconds)
ALERT_TIME=${ALERT_TIME}

# What to display if working for more than ALERT_TIME
ALERT_MESSAGE="${ALERT_MESSAGE}"

# How the notification is displayed (see 'notify-send --help')
ALERT_NOTIF="${ALERT_NOTIF}"

## Reminder

# What to display if not working
# Trick: to use a random message, put one message by line in a file (e.g.
# '$CONFIG_DIR/messages') and use
# QUESTION_MESSAGE="\$(shuf -n 1 \$CONFIG_DIR/messages)"
QUESTION_MESSAGE="${QUESTION_MESSAGE}"

# How the notification is displayed (see 'notify-send --help')
QUESTION_NOTIF="${QUESTION_NOTIF}"

## Display for notifications
DISPLAY=${DISPLAY}

## Snooze time
SNOOZE_TIME="${SNOOZE_TIME}"
EOC
}

function activate {
    rm -f "${SNOOZE_FILE}"
}

function snooze {
    local d="$@"
    if [ -z "$d" ] ; then
        d="$SNOOZE_TIME"
    fi
    date -d "$d" +%s >| "${SNOOZE_FILE}"
}

function status {
    if [ -f "${SNOOZE_FILE}" ] ; then
        local t=$(cat "${SNOOZE_FILE}")
        echo "Snoozed until $(date -d "@$t" +'%x %X')"
    else
        echo "Active"
    fi
}

function _check_snooze {
    if [ -f "${SNOOZE_FILE}" ] ; then
        local t=$(cat "${SNOOZE_FILE}")
        if [ $t -le $(date +%s) ] ; then
            activate
        else
            exit 0
        fi
    fi
}

function notify {
    _check_snooze
    $WATSON_STATUS |
    sed -r '
        s!^Project !!g;
        s!([^ ]+).+started .* ago \(([^)]+)\)!\1 \2!g
    ' | while read name date; do
        if [ $name == "No" -a "$date" == "project started." ] ; then
            $NOTIFY $QUESTION_NOTIF "Watson" "$QUESTION_MESSAGE"
            exit 0
        fi
        now=$(date +%s)
        ts=$(date -d "$(echo $date | tr '.' '-')" +%s)
        duration=$((now - ts))
        if [ $duration -ge $ALERT_TIME ] ; then
            $NOTIFY $ALERT_NOTIF "Watson" "$(printf "$ALERT_MESSAGE" $name)"
        fi
    done
}

#------------------------------------
if [ -d $(dirname ${RUNTIME}) ] ; then
    mkdir -p "${RUNTIME}"
else
    # not in a WM session
    exit 0
fi

case $1 in
    -h|--help) usage; exit 0;;
    -v|--version) echo "$(basename $0) $VERSION" ; exit 0;;
    -c|--config) config; exit 0;;
    -a|--activate) activate; exit 0;;
    -s|--snooze) shift; snooze "$@"; exit 0;;
    -V|--status) status; exit 0;;
    *) notify ; exit 0;;
esac
