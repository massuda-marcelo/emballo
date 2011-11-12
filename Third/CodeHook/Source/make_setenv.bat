set DHOME="c:\program files\borland\delphi7"
set DDCC32=dcc32
set DBPL="%DHOME%\Projects\Bpl"
set DUNIT="%DHOME%\Lib\Debug"
set DRES="%DHOME%\Lib"
set DISASM32="D:\DelphiComponent\Disasm32\Source"
set OUTPUT=..\Output
set NAME_DLL=chook.dll
set NAME_LIB_OMF=CodeHook_bc.lib
set NAME_DLL_LIB_OMF=CodeHook_dll_bc.lib
set NAME_DLL_LIB_COFF=CodeHook_dll_vc.lib

set DCC_CMD=-B -$A8 -$B- -$C- -$D- -$E- -$F- -$G+ -$H+ -$I+ -$J- -$K- -$L- -$M- -$N+ -$O+ -$P+ -$Q- -$R- -$S- -$T- -$U- -$V+ -$W- -$X+ -$Y- -$Z1 -cg -AWinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE; -H+ -W+ -M -$M16384,1048576 -K$00400000 -E"%OUTPUT%" -N"%OUTPUT%" -LE"c:\program files\borland\delphi7\Projects\Bpl" -LN"c:\program files\borland\delphi7\Projects\Bpl" -U%DISASM32% -O%DISASM32% -I%DISASM32% -R%DISASM32% -DDEBUG -w-UNSAFE_TYPE -w-UNSAFE_CODE -w-UNSAFE_CAST
