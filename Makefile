MAJOR	?= 3
MINOR	?= 0

TAG		= g0dscookie/rspamd
TAGLIST		= -t ${TAG}:${MAJOR} -t ${TAG}:${MAJOR}.${MINOR}
BUILDARGS	= --build-arg MAJOR=${MAJOR} --build-arg MINOR=${MINOR}

PLATFORM_FLAGS  = --platform linux/amd64
PUSH            ?= --push

build:
	docker buildx build ${PUSH} ${PLATFORM_FLAGS} ${BUILDARGS} ${TAGLIST} .

latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
latest: build
.PHONY: build latest

amd64: PLATFORM_FLAGS := --platform linux/amd64
amd64: build
amd64-latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
amd64-latest: amd64
.PHONY: amd64 amd64-latest
