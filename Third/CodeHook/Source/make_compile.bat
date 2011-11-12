@echo off

if "%CHOOK%"=="" goto InternalUse

call make_setenv.bat

%DDCC32% %DCC_CMD% %* CHook.dpr

goto end

:InternalUse
@echo This batch file should only be executed from within another batch file.
:end

@echo on
