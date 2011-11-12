set BCCHOME=d:\bcc55
set BCCBIN=%BCCHOME%\bin
set BCCINC=%BCCHOME%\include
set BCCLIB=%BCCHOME%\lib
set BCC32=%BCCBIN%\bcc32
%BCC32% -I%BCCINC% -L%BCCLIB% -tW -v- -w-8057 -n.\Output CodeHookTest.cpp
rem %BCC32% -c -I%BCCINC% -v- -w-8057 -n.\Output CodeHookTest.cpp
rem ilink32 /Tpe /aa /Gn /x /c /j%BCCLIB% c0x32w  .\Output\CodeHookTest,.\Output\CodeHookTest,,%BCCLIB%\import32.lib  %BCCLIB%\cw32.lib ..\..\CodeHook_lib_bc.lib