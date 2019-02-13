#!/bin/bash

REPO=ticpu/gns3templates

docker build -t gns3templates:base src/base
[ ! -z $REPO ] && docker tag gns3templates:base ${REPO}:base

for F in src/*
do
	[ -e $F/.nobuild ] && continue
	docker build -t ${REPO}:${F##*/} $F
done
