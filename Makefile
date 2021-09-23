default: image

image:
	docker pull gcc:11.1.0
	docker build . \
		--file Dockerfile \
		--build-arg BUILDER_IMAGE=gcc:11.1.0 \
		--build-arg AUTODIFF_TARGET_BRANCH=v0.6.4 \
		--tag lwtnn/build-base:debug-local
