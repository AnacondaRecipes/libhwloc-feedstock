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
          # cuda-cudart-dev installs headers + libs into $BUILD_PREFIX (lib/ + include/)
          ./configure --enable-cuda --with-cuda=$BUILD_PREFIX --prefix=$PREFIX \
            --disable-cairo --disable-opencl --disable-nvml --disable-gl --disable-libudev
        elif [[ ${ROCM_COMPILATION} == "enabled" ]]; then
          ./configure --prefix=$PREFIX --enable-rsmi $DISABLES
        else
          ./configure --prefix=$PREFIX $DISABLES
        fi
        ;;
    win-*)
        export CPPFLAGS="$CPPFLAGS -Dputenv=_putenv -Dmktemp=_mktemp -Dopen=_open -Dunlink=_unlink -Dclose=_close -Dstrdup=_strdup"
        export HWLOC_LDFLAGS="-no-undefined"
        # Skip failing tests that are skipped on Linux x86_64 and OSX, but not skipped on windows
        sed -i "s|SUBDIRS += x86||g" tests/hwloc/Makefile.am
        sed -i "s|-Xlinker --output-def -Xlinker .libs/libhwloc.def||g" hwloc/Makefile.am
        autoreconf -ivf
        chmod +x configure
        if [[ ${cuda_compiler_version} != "None" ]]; then
          # cudart.lib path differs between CUDA 12.x (Library/lib) and 13.x (Library/lib/x64)
          if [[ ${cuda_compiler_version} == 12.* ]]; then
            CUDA_LIBDIR="$BUILD_PREFIX/Library/lib"
          else
            CUDA_LIBDIR="$BUILD_PREFIX/Library/lib/x64"
          fi
          # hwloc.m4 falls back to header+lib autoconf probes when pkg-config
          # cannot find cuda-$VERSION.pc (no .pc file shipped on Windows).
          # Inject conda CUDA paths via CPPFLAGS / LDFLAGS so the probe succeeds.
          export CPPFLAGS="$CPPFLAGS -I$BUILD_PREFIX/Library/include"
          export LDFLAGS="$LDFLAGS -L$CUDA_LIBDIR"
          ./configure --enable-cuda --prefix="$PREFIX" --libdir="$PREFIX/lib" \
            --disable-cairo --disable-opencl --disable-nvml --disable-gl --disable-libudev \
            --disable-static || (cat config.log; false)
        else
          ./configure --prefix="$PREFIX" --libdir="$PREFIX/lib" $DISABLES --disable-static || (cat config.log; false)
        fi
        patch_libtool
        make V=1
        ;;
esac

make -j${CPU_COUNT} V=1
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]] && [[ ${cuda_compiler_version} == "None" ]]; then
  make check -j${CPU_COUNT} V=1 -k
fi
make install V=1
