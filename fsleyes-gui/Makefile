APPID ?= wallen-fsleyes-gui
APPVER ?= 1.10.1
DOCKERID ?= wjallen/fsleyes-gui:1.10.1

deploy:
	python3 ../utils/manage_apps.py app.json 

build:
	docker build -t $(DOCKERID) .

test:
	docker run --rm -it --entrypoint=/bin/bash $(DOCKERID)

push:
	docker push $(DOCKERID)

gui:
	xhost + 127.0.0.1
	docker run -e DISPLAY=host.docker.internal:0 --entrypoint=fsleyes $(DOCKERID)
