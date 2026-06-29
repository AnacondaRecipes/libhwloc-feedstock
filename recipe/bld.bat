set "CUDA_CMAKE_ARGS="
if not "%cuda_compiler_version%"=="None" (
  rem Conda CUDA on Windows uses BUILD_PREFIX\Library as the toolkit root
  rem (include/, lib/, bin/nvcc.exe) — not the env root itself.
  set "CUDA_HOME=%BUILD_PREFIX%\Library"
  set "CUDA_PATH=%BUILD_PREFIX%\Library"
  set "CUDA_CMAKE_ARGS=-DHWLOC_WITH_CUDA=ON -DCUDAToolkit_ROOT=%BUILD_PREFIX%\Library"
  rem CUDA 13.x moved import libs from Library\lib to Library\lib\x64
  echo %cuda_compiler_version% | findstr /b "13." >nul && set "CUDA_CMAKE_ARGS=%CUDA_CMAKE_ARGS% -DCUDAToolkit_LIBRARY_DIR=%BUILD_PREFIX%\Library\lib\x64"
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
