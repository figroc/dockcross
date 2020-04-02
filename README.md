# dockcross

Cross build tool based on [dockcross](https://github.com/dockcross/dockcross).

## usage

Besides the usage from the dockcross, one can use the image built from this repository like this:

```
docker run --rm \
  --entrypoint bash \
  -v $(pwd)/dist:/dist \
  -e PLAT_PYVER=3.6 \
  -e SDIST_SPEC=s2geometry \
  figroc/dockcross:manylinux2010 \
  build-wheel-from-sdist
```

* -v $(pwd)/dist:/dist

  Mount the local input/output dir the into container.

* -e PLAT_PYVER=3.6

  Build wheel against python `3.6` only. If omitted, it will build against all the python versions available in this image.

* -e SDIST_SPEC=s2geometry

  Build wheel of `s2geometry` from [pypi](https://pypi.org). This configuration takes precedence over `SDIST_FILE`.

* -e SDIST_FILE=\*.tar.gz

  Build wheels of `*.tar.gz` which are located in `$(pwd)/dist` dir. The default value *is* `*.tar.gz`.

* build-wheel-from-sdist

  The building command. It can take an optional argument pointing to the mounted dir, which by default is `/dist`.


> There is an wrapper script to simplify the invoking:
> ```
> PLAT_PYVER=3.6 SDIST_SPEC=s2geometry ./build.sh
> ```

## cmake

As FindPython of cmake, the system config of pythons are not system-wide in this image. One have to set PYTHON_INCLUDE_DIRS and PYTHON_LIBRARIES from sysconfig package of the corresponding python version.

You can call the cmake with `-DPYTHON_INCLUDE_DIRS=...` against a CMakeLists.txt containing following snippet:
```
if (NOT PYTHON_INCLUDE_DIRS)
  find_package(PythonLibs REQUIRED)
endif()
```