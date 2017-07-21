build: | output
	docker build -t boot2docker .
	docker run -it --name boot2docker \
		-v ${PWD}/output:/tmp/output \
		boot2docker /make_iso.sh
	docker cp boot2docker:/pc-master.iso output/
	docker rm boot2docker

output:
	mkdir -p $@

buildinfo:
    GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
    GITSHA1=$(shell git rev-parse --short HEAD)
    DATE:=$(shell date)
    $(shell echo "${GIT_BRANCH} : ${GITSHA1} - ${DATE}" > pocketcluster.info)

clean:
	rm -rf output
	-docker rm boot2docker
	-docker rmi boot2docker

.PHONY: build
