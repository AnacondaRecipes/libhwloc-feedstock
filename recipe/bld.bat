set "CUDA_CMAKE_ARGS="
if not "%cuda_compiler_version%"=="None" (
  rem hwloc links cudart at build time; point CMake at conda CUDA in BUILD_PREFIX
  set "CUDA_HOME=%BUILD_PREFIX%\Library"
  set "CUDA_PATH=%BUILD_PREFIX%\Library"
  set "CUDA_CMAKE_ARGS=-DHWLOC_WITH_CUDA=ON -DCUDAToolkit_ROOT=%BUILD_PREFIX%"
)

cmake -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_SHARED_LIBS=ON ^
  -DHWLOC_WITH_LIBXML2=ON ^
  -DHWLOC_ENABLE_TESTING=OFF ^
  %CUDA_CMAKE_ARGS% ^
  %SRC_DIR%\contrib\windows-cmake
if %ERRORLEVEL% neq 0 exit 1

ninja -j%CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

ninja install
if %ERRORLEVEL% neq 0 exit 1
