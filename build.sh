#!/bin/bash
set -e
cd $(dirname ${BASH_SOURCE[0]})

DOCKERFILE_PATH=Dockerfile
DOCKER_TAG=${DOCKCROSS:-manylinux2010}
IMAGE_NAME="figroc/dockcross:${DOCKER_TAG}"
if ! docker pull ${IMAGE_NAME}; then
  . hooks/build
fi

docker run --rm --entrypoint bash \
  -v $(pwd)/${1:-dist}:/dist \
  ${PLAT_PYVER:+-e PLAT_PYVER=${PLAT_PYVER}} \
  ${SDIST_SPEC:+-e SDIST_SPEC=${SDIST_SPEC}} \
  ${SDIST_FILE:+-e SDIST_FILE=${SDIST_FILE}} \
  ${IMAGE_NAME} build-wheel-from-sdist
