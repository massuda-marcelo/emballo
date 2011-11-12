perl GenTestCase.pl

set DHOME="c:\program files\borland\delphi7"
set DDCC32=dcc32
set DBPL="%DHOME%\Projects\Bpl"
set DUNIT="%DHOME%\Lib\Debug"
set DRES="%DHOME%\Lib"

set OUTPUT=.\Output

mkdir %OUTPUT%

dcc32 -B -$A8 -$B- -$C+ -$D+ -$E- -$F- -$G+ -$H+ -$I+ -$J- -$K- -$L+ -$M- -$N+ -$O- -$P+ -$Q- -$R- -$S- -$T- -$U- -$V+ -$W+ -$X+ -$YD -$Z1 -cg -AWinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE; -H+ -W+ -M -$M16384,1048576 -K$00400000 -E"%OUTPUT%" -N"%OUTPUT%" -LE"%DBPL%" -LN"%DBPL%" -U"%DUNIT%;../../source" -O"%DUNIT%;../../source" -I"%DUNIT%;../../source" -R"%DRES%;../../source" -DDEBUG -w-UNSAFE_TYPE -w-UNSAFE_CODE -w-UNSAFE_CAST CodeHookTestCase.dpr