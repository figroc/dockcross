#!/bin/bash
set -e
cd $(dirname ${BASH_SOURCE[0]})

DOCKCROSS=${DOCKCROSS:-manylinux2010}
DOCKIMAGE="figroc/dockcross:${DOCKCROSS}"
if ! docker pull ${DOCKIMAGE}; then
  docker build . -t ${DOCKIMAGE} \
    --build-arg DOCKCROSS=${DOCKCROSS}
fi
docker run --rm \
  -v $(pwd)/${1:-dist}:/dist \
  --entrypoint bash \
  ${DOCKIMAGE} build-wheel-from-sdist
