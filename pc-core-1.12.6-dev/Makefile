build: | output
	docker build -t pc-core .
	docker run --name pc-core -v ${PWD}/output:/tmp/output pc-core /bin/bash
	docker cp pc-core:/boot2docker.iso ${PWD}/output/
	docker rm pc-core

output:
	mkdir -p $@

buildinfo:
    GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
    GITSHA1=$(shell git rev-parse --short HEAD)
    DATE:=$(shell date)
    $(shell echo "${GIT_BRANCH} : ${GITSHA1} - ${DATE}" > pocketcluster.info)

#clean:
#	rm -rf output
#	-docker rm boot2docker
#	-docker rmi boot2docker

.PHONY: build
