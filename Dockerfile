ARG DOCKCROSS=manylinux2010
FROM dockcross/${DOCKCROSS}-x64
LABEL maintainer="Figroc Chen<figroc@gmail.com>"

RUN yum install -y \
      bison-devel \
      bzip2-devel \
      flex-devel \
      gmp-devel \
      libffi-devel \
      libxml2-devel \
      openssl-devel \
      openssl-static \
      pcre-devel \
      zlib-devel && \
    yum clean all

ENV SWIG_VER=rel-3.0.12
RUN curl -fLO \
      https://github.com/swig/swig/archive/${SWIG_VER}.tar.gz && \
    tar xzf ${SWIG_VER}.tar.gz && cd swig-${SWIG_VER} && \
    ./autogen.sh && ./configure && make && make install && \
    cd .. && rm -rf *${SWIG_VER}*

RUN printf '%s\n' '#!/bin/bash' 'set -e' '' \
      'platv=3*' \
      'bdist=${1:-/dist}' \
      'sdist=${bdist}/${SDIST_FILE:-*.tar.gz}' \
      'if [[ -n ${SDIST_SPEC} ]]; then sdist=${SDIST_SPEC}; fi' \
      'if [[ -n ${PLAT_PYVER} ]]; then platv=${PLAT_PYVER//./}; fi' \
      'for pip in /opt/python/cp${platv}-cp${platv}*/bin/pip; do' \
      '  ${pip} -v --disable-pip-version-check wheel ${sdist}' \
      'done' \
      'for whl in *.whl; do' \
      '  auditwheel repair ${whl} \' \
      '    -w ${bdist} \' \
      '    --plat ${AUDITWHEEL_PLAT} \' \
      '    ${ELF_PATCHER:+--elf-patcher ${ELF_PATCHER}}' \
      'done' \
    > build-wheel-from-sdist
