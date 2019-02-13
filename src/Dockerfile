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

FROM ubuntu:bionic AS build

RUN apt-get update && \
	apt-get install -qy \
		build-essential \
		curl
WORKDIR /app/runit-docker
ADD https://github.com/pixers/runit-docker/raw/ac80adf953c4f533abb5d204575754e54b6b7b23/runit-docker runit-docker
ADD https://github.com/pixers/runit-docker/raw/ac80adf953c4f533abb5d204575754e54b6b7b23/runit-docker.c runit-docker.c
RUN gcc -shared -std=c99 -Wall -O2 -fPIC -D_POSIX_SOURCE -D_GNU_SOURCE -o runit-docker.so runit-docker.c -ldl

FROM ubuntu:bionic AS gns3-dockrouter

RUN echo "deb http://archive.ubuntu.com/ubuntu/ bionic main universe" > /etc/apt/sources.list && \
	echo "deb http://archive.ubuntu.com/ubuntu/ bionic-security main universe" >> /etc/apt/sources.list && \
	echo "deb http://archive.ubuntu.com/ubuntu/ bionic-updates main universe" >> /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -qy --no-install-recommends \
		bash-completion \
		bird \
		busybox \
		ifupdown \
		inotify-tools \
		iproute2 \
		iptables \
		keepalived \
		openvpn \
		psmisc \
		nano \
		runit \
		screen \
		vim && \
	apt-get clean && \
	busybox --install && \
	rm -r /var/lib/apt/lists/*

COPY --from=build /app/runit-docker/runit-docker.so /lib/runit-docker.so
COPY --from=build /app/runit-docker/runit-docker /sbin/runit-docker
RUN rm -r /etc/runit /etc/service && \
	chmod +x /sbin/runit-docker
COPY etc/ /etc/
COPY entrypoint.sh /
CMD ["/entrypoint.sh"]
