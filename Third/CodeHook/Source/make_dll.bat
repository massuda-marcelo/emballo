set CHOOK=1

call make_compile.bat

if errorlevel 1 goto end

move /Y %OUTPUT%\%NAME_DLL% ..\

:end
