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

check_config () {
	# Usage: check_config SOURCE TARGET_NAME
	# Check if configuration file or folder is missing and copy it from SOURCE.
	#
	# If TARGET_NAME exists in /etc/network, return 0.
	# If TARGET_NAME exists in /etc/disabled, return 1.
	# If TARGET_NAME doesn't exist, copy it from SOURCE and adjust permissions,
	# then return 2.
	local source="$1"
	local target_name="$2"
	local target_path="/etc/network"

	if [ ! -d "$target_path/disabled" ]; then
		install -d -m777 "$target_path/disabled"
	fi

	if [ -e "$target_path/$target_name" ]; then
		return 0
	fi

	if [ ! -e "$target_path/disabled/$target_name" ]; then
		cp -r "$source" "$target_path/disabled/$target_name"
		chmod -R a+rwX "$target_path/disabled/$target_name" 
	fi

	while [ -e "$target_path/disabled/$target_name" -o ! -e "$target_path/$target_name" ]
	do
		inotifywait -qq -e create,delete,move,moved_from,moved_to "$target_path/disabled/" "$target_path/"
		sleep 1
	done

	return 0
}
