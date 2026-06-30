@echo on

set "CUDA_CMAKE_ARGS="
if not "%cuda_compiler_version%"=="None" (
  rem Conda CUDA on Windows uses BUILD_PREFIX\Library as the toolkit root.
  set "CUDA_HOME=%BUILD_PREFIX%\Library"
  set "CUDA_PATH=%BUILD_PREFIX%\Library"

  if "%cuda_compiler_version:~0,3%"=="13." (
    set "CUDA_CMAKE_ARGS=-DHWLOC_WITH_CUDA=ON -DCUDAToolkit_ROOT=%BUILD_PREFIX%\Library -DCUDAToolkit_LIBRARY_DIR=%BUILD_PREFIX%\Library\lib\x64"
  ) else (
    set "CUDA_CMAKE_ARGS=-DHWLOC_WITH_CUDA=ON -DCUDAToolkit_ROOT=%BUILD_PREFIX%\Library"
  )
) else (
  set "CUDA_CMAKE_ARGS=-DHWLOC_WITH_CUDA=OFF"
)

cmake -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_SHARED_LIBS=ON ^
  -DHWLOC_WITH_LIBXML2=ON ^
  -DHWLOC_ENABLE_TESTING=OFF ^
  %CUDA_CMAKE_ARGS% ^
  "%SRC_DIR%\contrib\windows-cmake"

if errorlevel 1 exit /b 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit /b 1

ninja install
if errorlevel 1 exit /b 1