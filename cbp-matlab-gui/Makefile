APPID ?= wallen-cbp-matlab-gui
APPVER ?= 1.0.0
DOCKERID ?= wjallen/cbp-matlab-gui:1.0.0

deploy:
	python3 ../utils/manage_apps.py app.json 

build:
	docker build -t $(DOCKERID) .

test:
	docker run --rm -it --entrypoint=/bin/bash $(DOCKERID)

push:
	docker push $(DOCKERID)
