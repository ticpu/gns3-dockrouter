#!/bin/sh

env | egrep -v '^PATH=' >> /etc/environment
ifup -a
exec runit-docker
