@echo off

if "%CHOOK%"=="" goto InternalUse

call make_compile.bat -JP

move /Y *.obj %OUTPUT%\
if errorlevel 1 goto end
move /Y %DISASM32%\*.obj %OUTPUT%\
if errorlevel 1 goto end

goto end

:InternalUse
@echo This batch file should only be executed from within another batch file.
:end

@echo on
