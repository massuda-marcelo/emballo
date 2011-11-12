set CHOOK=1

call make_objs.bat
if errorlevel 1 goto end

cd %OUTPUT%
if errorlevel 1 goto end

del %NAME_LIB_OMF%
tlib %NAME_LIB_OMF% + CodeHook.obj
if errorlevel 1 goto end
tlib %NAME_LIB_OMF% + CodeHookIntf.obj
if errorlevel 1 goto end
tlib %NAME_LIB_OMF% + DisAsm32.obj
if errorlevel 1 goto end

if not "%1"=="nomove" move /Y %NAME_LIB_OMF% ..\

:end
