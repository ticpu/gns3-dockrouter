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
	apt-get dist-upgrade -qy && \
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
	apt-get dist-upgrade -qy && \
	apt-get install -qy --no-install-recommends \
		bash-completion \
		bird \
		busybox \
		easy-rsa \
		ifupdown \
		inotify-tools \
		iproute2 \
		iptables \
		iputils-arping \
		iputils-ping \
		iputils-tracepath \
		keepalived \
		lldpd \
		openvpn \
		psmisc \
		mtr-tiny \
		nano \
		runit \
		tcpdump \
		vim && \
	apt-get install -qy quagga && \
	apt-get clean && \
	busybox --install && \
	rm -r /var/lib/apt/lists/*

COPY etc/dockrouter/openvpn-ca/ /etc/dockrouter/openvpn-ca/
WORKDIR /etc/dockrouter/openvpn-ca
RUN /bin/bash -c "exec 2>&1 && \
	rm -f /dev/random && \
	ln -s /dev/urandom /dev/random && \
	ln -s /usr/share/easy-rsa/* . && \
	ln -s openssl-1.0.0.cnf openssl.cnf && \
	. ./vars-dockrouter && \
	./clean-all && \
	rm pkitool && \
	sed -r -e 's/-newkey rsa:[^ ]+//' -e 's/-keyout /-key /' /usr/share/easy-rsa/pkitool > pkitool && \
	chmod +x pkitool && \
	install -m0600 -t keys/ ca.key ta.key && \
	cp dh2048.pem keys/ && \
	./pkitool --initca && \
	ln -sf /usr/share/easy-rsa/pkitool && \
	for I in {1..9}; \
	do \
		yes '' | ./pkitool --pkcs12 client-\$I 2>/dev/null && \
		yes '' | ./pkitool --server --pkcs12 server-\$I 2>/dev/null; \
	done"
COPY --from=build /app/runit-docker/runit-docker.so /lib/runit-docker.so
COPY --from=build /app/runit-docker/runit-docker /sbin/runit-docker
RUN rm -r /etc/runit /etc/quagga /etc/service && \
	chmod +x /sbin/runit-docker && \
	ln -s /etc/network/quagga /etc/quagga && \
	mv /usr/sbin/tcpdump /usr/bin/
COPY etc/ /etc/
WORKDIR /
COPY entrypoint.sh /
CMD ["/entrypoint.sh"]
