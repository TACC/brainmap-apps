APPID ?= wallen-datalad-gui
APPVER ?= 0.2.0
DOCKERID ?= wjallen/datalad-gui:0.2.0

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
	docker run -e DISPLAY=host.docker.internal:0 --entrypoint=/app/miniconda3/bin/datalad-gooey $(DOCKERID)
