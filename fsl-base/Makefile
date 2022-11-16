all: build-fsl-cuda run-fsl-cuda

build-fsl-cuda:
	docker build -t wjallen/fsl-cuda:6.0.5-11.4 -f Dockerfile_fsl_6.0.5_cuda_11.4 .

run-fsl-cuda:
	docker run --rm -it wjallen/fsl-cuda:6.0.5-11.4 /bin/bash

push-fsl-cuda:
	docker push wjallen/fsl-cuda:6.0.5-11.4

build-fsl:
	docker build -t wjallen/fsl:6.0.5 -f Dockerfile_fsl_6.0.5 .

run-fsl:
	docker run --rm -it wjallen/fsl:6.0.5 /bin/bash

push-fsl:
	docker push wjallen/fsl:6.0.5
