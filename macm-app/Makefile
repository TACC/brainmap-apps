APPID ?= wallen-macm
APPVER ?= 1.0.1
DOCKERID ?= wjallen/macm:1.0.1

deploy:
	python3 ../utils/manage_apps.py app.json 

build:
	docker build -t $(DOCKERID) .

test:
	docker run --rm -it --entrypoint=/bin/bash $(DOCKERID)

push:
	docker push $(DOCKERID)
