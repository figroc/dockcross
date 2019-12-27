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
      pcre-devel \
      zlib-devel && \
    yum clean all

ENV SWIG_VER=rel-3.0.12
RUN curl -fLO \
      https://github.com/swig/swig/archive/${SWIG_VER}.tar.gz && \
    tar xzf ${SWIG_VER}.tar.gz && cd swig-${SWIG_VER} && \
    ./autogen.sh && ./configure && make && make install && \
    cd .. && rm -rf *${SWIG_VER}*

RUN for py3 in /opt/python/cp3*/bin/python3; do \
      export ver=$(${py3} --version | cut -d' ' -f2) && \
      curl -fLO \
        https://www.python.org/ftp/python/${ver/[a-z]*/}/Python-${ver}.tgz && \
      tar xzf Python-${ver}.tgz && cd Python-${ver} && \
      ./configure --enable-shared --enable-optimizations && make altinstall && \
      cd .. && rm -rf Python-${ver}* || exit 1; \
    done

ENV WHEEL_VER=wheel-0.32.3-py2.py3-none-any.whl
RUN curl -fLO \
      https://files.pythonhosted.org/packages/ff/47/1dfa4795e24fd6f93d5d58602dd716c3f101cfd5a77cd9acbe519b44a0a9/${WHEEL_VER} && \
    for pip in /usr/local/bin/pip3.*; do \
      ${pip} --no-cache-dir install --no-index ${WHEEL_VER} || exit 1; \
    done && rm -rf ${WHEEL_VER}

RUN printf '%s\n' '#!/bin/bash' 'set -e' \
      'dist=${1:-/dist}' \
      'for pip in /usr/local/bin/pip${PLAT_PYVER:-3.*}; do' \
      '  if [[ -n ${SDIST_SPEC} ]]; then' \
      '    sdist=${SDIST_SPEC}' \
      '  else' \
      '    sdist=${dist}/${SDIST_FILE:-*.tar.gz}' \
      '  fi' \
      '  ${pip} -v wheel ${sdist}' \
      'done' \
      'for whl in *.whl; do' \
      '  auditwheel repair ${whl} \' \
      '    -w ${dist} \' \
      '    --plat ${AUDITWHEEL_PLAT} \' \
      '    ${ELF_PATCHER:+--elf-patcher ${ELF_PATCHER}}' \
      'done' \
    > build-wheel-from-sdist
