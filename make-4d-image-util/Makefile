APPID ?= wallen-make-4d-image
APPVER ?= 1.0.0
DOCKERID ?= wjallen/make-4d-image:1.0.0

deploy:
	python3 ../utils/manage_apps.py app.json 

build:
	docker build -t $(DOCKERID) .

test:
	docker run --rm -it --entrypoint=/bin/bash $(DOCKERID)

push:
	docker push $(DOCKERID)
