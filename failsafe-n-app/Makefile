APPID ?= wallen-failsafe-n
APPVER ?= 3.0.2
DOCKERID ?= wjallen/failsafe-n:1.0.0

deploy:
	python3 ../utils/manage_apps.py app.json 

build:
	docker build -t $(DOCKERID) .

test:
	docker run --rm -it --entrypoint=/bin/bash $(DOCKERID)

push:
	docker push $(DOCKERID)
