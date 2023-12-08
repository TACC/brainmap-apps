APPID ?= wallen-sleuth-taccdb-gui
APPVER ?= 3.0.4
DOCKERID ?= wjallen/sleuth-taccdb-gui:3.0.4

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
	docker run -e DISPLAY=host.docker.internal:0 --entrypoint=java $(DOCKERID) -cp /app/src/Sleuth.jar org.brainmap.Sleuth
