APPID ?= wallen-gingerale-pval
APPVER ?= 3.0.2
DOCKERID ?= wjallen/gingerale-pval:3.0.2

deploy:
	python3 ../utils/manage_apps.py app.json 

build:
	docker build -t $(DOCKERID) .

test:
	docker run --rm -it --entrypoint=/bin/bash $(DOCKERID)

push:
	docker push $(DOCKERID)