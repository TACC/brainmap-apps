build:
	docker build -t wallen/sleuth:3.0.4 .

run:
	xhost + 127.0.0.1
	docker run -e DISPLAY=host.docker.internal:0 wallen/sleuth:3.0.4 java -jar /app/Sleuth.jar

inter:
	docker run --rm -it wallen/sleuth:3.0.4 /bin/bash
