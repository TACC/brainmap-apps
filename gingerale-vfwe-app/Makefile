APPID ?= wallen-gingerale-vfwe
APPVER ?= 3.0.2
DOCKERID ?= wjallen/gingerale-vfwe:3.0.2

deploy:
	python3 ../utils/manage_apps.py app.json 

build:
	docker build -t $(DOCKERID) .

test:
	docker run --rm -it --entrypoint=/bin/bash $(DOCKERID)

push:
	docker push $(DOCKERID)
