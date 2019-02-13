FROM ubuntu:bionic AS gns3template-build

RUN apt-get update && \
	apt-get install -qy \
		build-essential \
		git
WORKDIR /app
RUN git clone -q https://github.com/pixers/runit-docker.git
WORKDIR /app/runit-docker
RUN git fetch && \
	git reset --hard origin/master && \
	gcc -shared -std=c99 -Wall -O2 -fPIC -D_POSIX_SOURCE -D_GNU_SOURCE -o runit-docker.so runit-docker.c -ldl

FROM ubuntu:bionic AS gns3template-base

RUN echo "deb http://archive.ubuntu.com/ubuntu/ bionic main universe" > /etc/apt/sources.list && \
	echo "deb http://archive.ubuntu.com/ubuntu/ bionic-security main universe" >> /etc/apt/sources.list && \
	echo "deb http://archive.ubuntu.com/ubuntu/ bionic-updates main universe" >> /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -qy --no-install-recommends \
		bash-completion \
		bird \
		busybox \
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

RUN rm -r /etc/runit /etc/service
COPY --from=gns3template-build /app/runit-docker/runit-docker.so /lib/runit-docker.so
COPY --from=gns3template-build /app/runit-docker/runit-docker /sbin/runit-docker
COPY profile /etc/profile.d/docker.sh
COPY service/ /etc/service/
COPY entrypoint.sh /
CMD ["/entrypoint.sh"]
