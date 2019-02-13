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

SVDIR=/etc/service
CONFDIR=/etc/network

find_config_name () {
	local config_name_file="/etc/service/$1/configname"
	[ -s "$config_name_file" ] || return 1
	cat "$config_name_file"
}

find_service_name () {
	grep -lx "$1" $SVDIR/*/configname | \
		sed -rne 's|/?etc/service/([^/]+)/configname|\1|p'
}

check_service_start () {
	[ -e "$CONFDIR/disabled/$1" -o ! -e "$CONFDIR/$1" ]
}

check_config () {
	# Usage: check_config SOURCE SERVICE_NAME
	# Check if configuration file or folder is missing and copy it from SOURCE.
	#
	# If TARGET_NAME is missing, copy it from SOURCE and adjust permissions,
	# If TARGET_NAME exists in /etc/network and not ./disabled, return 0.
	# If TARGET_NAME exists in /etc/network/disabled or is missing from
	# /etc/network, sv stop $SERVICE_NAME.
	local source="$1"
	local service_name="$2"
	local config_name="`find_config_name $service_name`"

	if [ ! -d "$CONFDIR/disabled" ]; then
		install -d -m777 "$CONFDIR/disabled"
	fi

	if [ -z "$config_name" ]; then
		sv down "$service_name"
		return 1
	fi

	if [ ! -e "$CONFDIR/$config_name" -a ! -e "$CONFDIR/disabled/$config_name" ]; then
		cp -r "$source" "$CONFDIR/disabled/$config_name"
		chmod -R a+rwX "$CONFDIR/disabled/$config_name"
	fi

	if check_service_start "$config_name"; then
		sv down "$service_name"
		return 1
	fi

	return 0
}
