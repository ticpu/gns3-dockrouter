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

COPY profile /etc/profile.d/runsvdir.sh
COPY runit/ /etc/runit/
CMD ["/bin/sh", "-c", "env | egrep -v '^PATH=' >> /etc/environment; exec /sbin/runit"]
