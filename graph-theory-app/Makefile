APPID ?= wallen-graph-theory
APPVER ?= 1.0.0
DOCKERID ?= wjallen/graph-theory:1.0.0

deploy:
	python3 ../utils/manage_apps.py app.json 

build:
	docker build -t $(DOCKERID) .

test:
	docker run --rm -it --entrypoint=/bin/bash $(DOCKERID)

push:
	docker push $(DOCKERID)
