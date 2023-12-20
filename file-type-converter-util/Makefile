APPID ?= wallen-file-type-converter
APPVER ?= 1.0.0
DOCKERID ?= wjallen/file-type-converter:1.0.0

deploy:
	python3 ../utils/manage_apps.py app.json 

build:
	docker build -t $(DOCKERID) .

test:
	docker run --rm -it --entrypoint=/bin/bash $(DOCKERID)

push:
	docker push $(DOCKERID)
