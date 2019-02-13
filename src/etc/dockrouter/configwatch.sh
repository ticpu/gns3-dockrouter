#!/bin/bash

. /etc/dockrouter/functions.sh

process_action () {
	local watch="$1"
	local action="$2"
	local filename="$3"
	local service_name="`find_service_name $filename`"

	case "$action" in
		*CLOSE_WRITE*)
			sv reload "$service_name"
		;;

		*)
			if check_service_start "$filename"; then
				sv down "$service_name"
			else
				sv up "$service_name"
			fi
		;;
	esac
}

[ -d "$CONFDIR" ] || {
	echo "$CONFDIR is missing." 1>&2
	exit 1
}

[ -d "$CONFDIR/disabled" ] || install -d -m777 "$CONFDIR/disabled"

inotifywait -qme create,delete,move,close_write "$CONFDIR/disabled" "$CONFDIR" | \
	while read WATCH ACTION FILENAME
	do
		process_action "$WATCH" "$ACTION" "$FILENAME"
	done
