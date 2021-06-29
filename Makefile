default: image

image:
	docker pull gcc:11.1.0
	docker build . \
		--file Dockerfile \
		--build-arg BUILDER_IMAGE=gcc:11.1.0 \
		--tag lwtnn/build-base:debug-local
