build: | output
	docker build -t boot2docker .
	docker run -it --name boot2docker \
		-v ${PWD}/output:/tmp/output \
		boot2docker /make_iso.sh
	docker cp boot2docker:/boot2docker.iso output/

output:
	mkdir -p $@

clean:
	rm -rf output
	-docker rm boot2docker
	-docker rmi boot2docker

.PHONY: build
