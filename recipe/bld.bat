cmake -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_SHARED_LIBS=ON ^
  -DHWLOC_WITH_LIBXML2=ON ^
  -DHWLOC_ENABLE_TESTING=OFF ^
  %SRC_DIR%\contrib\windows-cmake
if %ERRORLEVEL% neq 0 exit 1

ninja -j%CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

ninja install
if %ERRORLEVEL% neq 0 exit 1
