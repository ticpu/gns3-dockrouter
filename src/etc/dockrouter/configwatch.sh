#!/bin/bash
# Copyright 2019 Jérôme Poulin <jeromepoulin@gmail.com>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
