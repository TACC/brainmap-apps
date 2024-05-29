APPID ?= wallen-sdm-gui
APPVER ?= 6.23beta
DOCKERID ?= wjallen/sdm-gui:6.23beta

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
	docker run -e DISPLAY=host.docker.internal:0 -e LD_LIBRARY_PATH=/app/src/SdmPsiGui-linux64-v6.23/bin/linux64 --entrypoint=/app/src/SdmPsiGui-linux64-v6.23/bin/linux64/SdmPsiGui $(DOCKERID)
