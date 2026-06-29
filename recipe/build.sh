#!/bin/bash

set -e

DISABLES="--disable-cairo --disable-opencl --disable-cuda --disable-nvml"
DISABLES="$DISABLES --disable-gl --disable-libudev"

chmod +x configure

case "${target_platform:-${TARGET_PLATFORM}}" in
    osx-*)
        autoreconf -ivf
        ./configure --prefix=$PREFIX $DISABLES || (cat config.log; false)
        ;;
    linux-*)
        autoreconf -ivf
        export LDFLAGS="${LDFLAGS} -Wl,--as-needed"
        if [[ ${cuda_compiler_version} != "None" ]]; then
          ./configure --enable-cuda --prefix=$PREFIX --disable-cairo --disable-opencl --disable-gl --disable-libudev
        elif [[ ${ROCM_COMPILATION} == "enabled" ]]; then
          ./configure --prefix=$PREFIX --enable-rsmi $DISABLES
        else
          ./configure --prefix=$PREFIX $DISABLES
        fi
        ;;
esac

make -j${CPU_COUNT} V=1
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]] && [[ ${cuda_compiler_version} == "None" ]]; then
  make check -j${CPU_COUNT} V=1 -k
fi
make install V=1
