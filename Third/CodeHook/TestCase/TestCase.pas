unit TestCase;

interface

uses
  SysUtils, CodeHookIntf;

type
  DummyType = Integer;

{#@Type}
  TTestTarget = class
    function ObjTestTarget_reg0: Integer;
    function ObjTestTarget_reg1(Arg0: Integer): Integer;
    function ObjTestTarget_reg2(Arg0: Integer; Arg1: Integer): Integer;
    function ObjTestTarget_reg3(Arg0: Integer; Arg1: Integer; Arg2: Integer): Integer;
    function ObjTestTarget_reg4(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer): Integer;
    function ObjTestTarget_reg5(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer): Integer;
    function ObjTestTarget_reg6(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer): Integer;
    function ObjTestTarget_reg7(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer): Integer;
    function ObjTestTarget_reg8(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer): Integer;
    function ObjTestTarget_reg9(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer): Integer;
    function ObjTestTarget_reg10(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer): Integer;
    function ObjTestTarget_reg11(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer): Integer;
    function ObjTestTarget_reg12(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer): Integer;
    function ObjTestTarget_reg13(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer): Integer;
    function ObjTestTarget_reg14(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer): Integer;
    function ObjTestTarget_reg15(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer): Integer;
    function ObjTestTarget_reg16(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer): Integer;
    function ObjTestTarget_reg17(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer): Integer;
    function ObjTestTarget_reg18(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer; Arg17: Integer): Integer;
    function ObjTestTarget_reg19(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer; Arg17: Integer; Arg18: Integer): Integer;
  end;

  TTestHook = class
    function ObjTestHook_reg0(AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
    function ObjTestHook_reg1(Arg0: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
    function ObjTestHook_reg2(Arg0: Integer; Arg1: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
    function ObjTestHook_reg3(Arg0: Integer; Arg1: Integer; Arg2: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
    function ObjTestHook_reg4(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
    function ObjTestHook_reg5(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
    function ObjTestHook_reg6(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
    function ObjTestHook_reg7(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
    function ObjTestHook_reg8(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
    function ObjTestHook_reg9(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
  end;

function GTestTarget_reg0: Integer;
function GTestTarget_reg1(Arg0: Integer): Integer;
function GTestTarget_reg2(Arg0: Integer; Arg1: Integer): Integer;
function GTestTarget_reg3(Arg0: Integer; Arg1: Integer; Arg2: Integer): Integer;
function GTestTarget_reg4(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer): Integer;
function GTestTarget_reg5(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer): Integer;
function GTestTarget_reg6(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer): Integer;
function GTestTarget_reg7(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer): Integer;
function GTestTarget_reg8(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer): Integer;
function GTestTarget_reg9(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer): Integer;
function GTestTarget_reg10(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer): Integer;
function GTestTarget_reg11(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer): Integer;
function GTestTarget_reg12(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer): Integer;
function GTestTarget_reg13(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer): Integer;
function GTestTarget_reg14(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer): Integer;
function GTestTarget_reg15(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer): Integer;
function GTestTarget_reg16(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer): Integer;
function GTestTarget_reg17(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer): Integer;
function GTestTarget_reg18(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer; Arg17: Integer): Integer;
function GTestTarget_reg19(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer; Arg17: Integer; Arg18: Integer): Integer;
function GTestHook_reg0(AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
function GTestHook_reg1(Arg0: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
function GTestHook_reg2(Arg0: Integer; Arg1: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
function GTestHook_reg3(Arg0: Integer; Arg1: Integer; Arg2: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
function GTestHook_reg4(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
function GTestHook_reg5(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
function GTestHook_reg6(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
function GTestHook_reg7(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
function GTestHook_reg8(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
function GTestHook_reg9(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
{#@Type}

procedure DoTestCase;

var
  GCodeHook: ICodeHook;
  GCodeHookHelper: ICodeHookHelper;
  ExtraParams: array[0 .. 128] of Integer;

implementation

var
  ObjTestTarget: TTestTarget;
  ObjTestHook: TTestHook;

procedure CheckValue(AExpect: Integer; AValue: Integer); overload;
begin
  if AExpect <> AValue then
  begin
    WriteLn(Format('CheckValue error: Expect %d Value %d', [ AExpect, AValue ]));
    asm int 3 end;
  end;
end;

procedure CheckValue(AExpect: Double; AValue: Double); overload;
begin
  if AExpect <> AValue then
  begin
    asm int 3 end;
  end;
end;

procedure CheckAssert(AValue: Boolean);
begin
  if not AValue then
  begin
    asm int 3 end;
  end;
end;

{#@Functions}
function TTestTarget.ObjTestTarget_reg0: Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := 0;
end;

function TTestTarget.ObjTestTarget_reg1(Arg0: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1;
end;

function TTestTarget.ObjTestTarget_reg2(Arg0: Integer; Arg1: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2;
end;

function TTestTarget.ObjTestTarget_reg3(Arg0: Integer; Arg1: Integer; Arg2: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3;
end;

function TTestTarget.ObjTestTarget_reg4(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4;
end;

function TTestTarget.ObjTestTarget_reg5(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5;
end;

function TTestTarget.ObjTestTarget_reg6(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6;
end;

function TTestTarget.ObjTestTarget_reg7(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7;
end;

function TTestTarget.ObjTestTarget_reg8(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8;
end;

function TTestTarget.ObjTestTarget_reg9(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9;
end;

function TTestTarget.ObjTestTarget_reg10(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10;
end;

function TTestTarget.ObjTestTarget_reg11(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11;
end;

function TTestTarget.ObjTestTarget_reg12(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12;
end;

function TTestTarget.ObjTestTarget_reg13(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13;
end;

function TTestTarget.ObjTestTarget_reg14(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14;
end;

function TTestTarget.ObjTestTarget_reg15(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14 + Arg14*15;
end;

function TTestTarget.ObjTestTarget_reg16(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14 + Arg14*15 + Arg15*16;
end;

function TTestTarget.ObjTestTarget_reg17(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14 + Arg14*15 + Arg15*16 + Arg16*17;
end;

function TTestTarget.ObjTestTarget_reg18(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer; Arg17: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14 + Arg14*15 + Arg15*16 + Arg16*17 + Arg17*18;
end;

function TTestTarget.ObjTestTarget_reg19(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer; Arg17: Integer; Arg18: Integer): Integer;
begin
  CheckAssert(Self = ObjTestTarget);
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14 + Arg14*15 + Arg15*16 + Arg16*17 + Arg17*18 + Arg18*19;
end;

function GTestTarget_reg0: Integer;
begin
  Result := 0;
end;

function GTestTarget_reg1(Arg0: Integer): Integer;
begin
  Result := Arg0*1;
end;

function GTestTarget_reg2(Arg0: Integer; Arg1: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2;
end;

function GTestTarget_reg3(Arg0: Integer; Arg1: Integer; Arg2: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3;
end;

function GTestTarget_reg4(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4;
end;

function GTestTarget_reg5(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5;
end;

function GTestTarget_reg6(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6;
end;

function GTestTarget_reg7(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7;
end;

function GTestTarget_reg8(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8;
end;

function GTestTarget_reg9(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9;
end;

function GTestTarget_reg10(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10;
end;

function GTestTarget_reg11(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11;
end;

function GTestTarget_reg12(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12;
end;

function GTestTarget_reg13(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13;
end;

function GTestTarget_reg14(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14;
end;

function GTestTarget_reg15(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14 + Arg14*15;
end;

function GTestTarget_reg16(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14 + Arg14*15 + Arg15*16;
end;

function GTestTarget_reg17(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14 + Arg14*15 + Arg15*16 + Arg16*17;
end;

function GTestTarget_reg18(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer; Arg17: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14 + Arg14*15 + Arg15*16 + Arg16*17 + Arg17*18;
end;

function GTestTarget_reg19(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; Arg9: Integer; Arg10: Integer; Arg11: Integer; Arg12: Integer; Arg13: Integer; Arg14: Integer; Arg15: Integer; Arg16: Integer; Arg17: Integer; Arg18: Integer): Integer;
begin
  Result := Arg0*1 + Arg1*2 + Arg2*3 + Arg3*4 + Arg4*5 + Arg5*6 + Arg6*7 + Arg7*8 + Arg8*9 + Arg9*10 + Arg10*11 + Arg11*12 + Arg12*13 + Arg13*14 + Arg14*15 + Arg15*16 + Arg16*17 + Arg17*18 + Arg18*19;
end;

function TTestHook.ObjTestHook_reg0(AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin
  CheckAssert(Self = ObjTestHook);


  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function TTestHook.ObjTestHook_reg1(Arg0: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin
  CheckAssert(Self = ObjTestHook);

  CheckValue(ExtraParams[0], Arg0);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function TTestHook.ObjTestHook_reg2(Arg0: Integer; Arg1: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin
  CheckAssert(Self = ObjTestHook);

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function TTestHook.ObjTestHook_reg3(Arg0: Integer; Arg1: Integer; Arg2: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin
  CheckAssert(Self = ObjTestHook);

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function TTestHook.ObjTestHook_reg4(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin
  CheckAssert(Self = ObjTestHook);

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function TTestHook.ObjTestHook_reg5(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin
  CheckAssert(Self = ObjTestHook);

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);
  CheckValue(ExtraParams[4], Arg4);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function TTestHook.ObjTestHook_reg6(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin
  CheckAssert(Self = ObjTestHook);

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);
  CheckValue(ExtraParams[4], Arg4);
  CheckValue(ExtraParams[5], Arg5);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function TTestHook.ObjTestHook_reg7(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin
  CheckAssert(Self = ObjTestHook);

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);
  CheckValue(ExtraParams[4], Arg4);
  CheckValue(ExtraParams[5], Arg5);
  CheckValue(ExtraParams[6], Arg6);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function TTestHook.ObjTestHook_reg8(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin
  CheckAssert(Self = ObjTestHook);

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);
  CheckValue(ExtraParams[4], Arg4);
  CheckValue(ExtraParams[5], Arg5);
  CheckValue(ExtraParams[6], Arg6);
  CheckValue(ExtraParams[7], Arg7);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function TTestHook.ObjTestHook_reg9(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin
  CheckAssert(Self = ObjTestHook);

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);
  CheckValue(ExtraParams[4], Arg4);
  CheckValue(ExtraParams[5], Arg5);
  CheckValue(ExtraParams[6], Arg6);
  CheckValue(ExtraParams[7], Arg7);
  CheckValue(ExtraParams[8], Arg8);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function GTestHook_reg0(AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin


  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function GTestHook_reg1(Arg0: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin

  CheckValue(ExtraParams[0], Arg0);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function GTestHook_reg2(Arg0: Integer; Arg1: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function GTestHook_reg3(Arg0: Integer; Arg1: Integer; Arg2: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function GTestHook_reg4(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function GTestHook_reg5(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);
  CheckValue(ExtraParams[4], Arg4);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function GTestHook_reg6(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);
  CheckValue(ExtraParams[4], Arg4);
  CheckValue(ExtraParams[5], Arg5);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function GTestHook_reg7(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);
  CheckValue(ExtraParams[4], Arg4);
  CheckValue(ExtraParams[5], Arg5);
  CheckValue(ExtraParams[6], Arg6);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function GTestHook_reg8(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);
  CheckValue(ExtraParams[4], Arg4);
  CheckValue(ExtraParams[5], Arg5);
  CheckValue(ExtraParams[6], Arg6);
  CheckValue(ExtraParams[7], Arg7);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


function GTestHook_reg9(Arg0: Integer; Arg1: Integer; Arg2: Integer; Arg3: Integer; Arg4: Integer; Arg5: Integer; Arg6: Integer; Arg7: Integer; Arg8: Integer; AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor): Cardinal;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin

  CheckValue(ExtraParams[0], Arg0);
  CheckValue(ExtraParams[1], Arg1);
  CheckValue(ExtraParams[2], Arg2);
  CheckValue(ExtraParams[3], Arg3);
  CheckValue(ExtraParams[4], Arg4);
  CheckValue(ExtraParams[5], Arg5);
  CheckValue(ExtraParams[6], Arg6);
  CheckValue(ExtraParams[7], Arg7);
  CheckValue(ExtraParams[8], Arg8);

  GCodeHook.GetHookInfo(AHandle, @lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;


procedure TestCaseExecute;
begin
  CheckValue(0, ObjTestTarget.ObjTestTarget_reg0);
  CheckValue(1*1, ObjTestTarget.ObjTestTarget_reg1(1));
  CheckValue(1*1 + 1*2, ObjTestTarget.ObjTestTarget_reg2(1, 1));
  CheckValue(1*1 + 1*2 + 1*3, ObjTestTarget.ObjTestTarget_reg3(1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4, ObjTestTarget.ObjTestTarget_reg4(1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5, ObjTestTarget.ObjTestTarget_reg5(1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6, ObjTestTarget.ObjTestTarget_reg6(1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7, ObjTestTarget.ObjTestTarget_reg7(1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8, ObjTestTarget.ObjTestTarget_reg8(1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9, ObjTestTarget.ObjTestTarget_reg9(1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10, ObjTestTarget.ObjTestTarget_reg10(1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11, ObjTestTarget.ObjTestTarget_reg11(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12, ObjTestTarget.ObjTestTarget_reg12(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13, ObjTestTarget.ObjTestTarget_reg13(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14, ObjTestTarget.ObjTestTarget_reg14(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14 + 1*15, ObjTestTarget.ObjTestTarget_reg15(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14 + 1*15 + 1*16, ObjTestTarget.ObjTestTarget_reg16(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14 + 1*15 + 1*16 + 1*17, ObjTestTarget.ObjTestTarget_reg17(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14 + 1*15 + 1*16 + 1*17 + 1*18, ObjTestTarget.ObjTestTarget_reg18(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14 + 1*15 + 1*16 + 1*17 + 1*18 + 1*19, ObjTestTarget.ObjTestTarget_reg19(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(0, GTestTarget_reg0);
  CheckValue(1*1, GTestTarget_reg1(1));
  CheckValue(1*1 + 1*2, GTestTarget_reg2(1, 1));
  CheckValue(1*1 + 1*2 + 1*3, GTestTarget_reg3(1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4, GTestTarget_reg4(1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5, GTestTarget_reg5(1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6, GTestTarget_reg6(1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7, GTestTarget_reg7(1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8, GTestTarget_reg8(1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9, GTestTarget_reg9(1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10, GTestTarget_reg10(1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11, GTestTarget_reg11(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12, GTestTarget_reg12(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13, GTestTarget_reg13(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14, GTestTarget_reg14(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14 + 1*15, GTestTarget_reg15(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14 + 1*15 + 1*16, GTestTarget_reg16(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14 + 1*15 + 1*16 + 1*17, GTestTarget_reg17(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14 + 1*15 + 1*16 + 1*17 + 1*18, GTestTarget_reg18(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  CheckValue(1*1 + 1*2 + 1*3 + 1*4 + 1*5 + 1*6 + 1*7 + 1*8 + 1*9 + 1*10 + 1*11 + 1*12 + 1*13 + 1*14 + 1*15 + 1*16 + 1*17 + 1*18 + 1*19, GTestTarget_reg19(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
end;
procedure TestCaseTargetHook(AHookObj: Pointer; AHook: Pointer; ACC: Integer; AExtraParams: PCardinal; AExtraParamCount: Integer);
begin
  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg0, AHook, 0, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg0, AHook, 0, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg1, AHook, 1, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg1, AHook, 1, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg2, AHook, 2, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg2, AHook, 2, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg3, AHook, 3, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg3, AHook, 3, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg4, AHook, 4, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg4, AHook, 4, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg5, AHook, 5, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg5, AHook, 5, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg6, AHook, 6, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg6, AHook, 6, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg7, AHook, 7, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg7, AHook, 7, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg8, AHook, 8, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg8, AHook, 8, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg9, AHook, 9, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg9, AHook, 9, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg10, AHook, 10, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg10, AHook, 10, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg11, AHook, 11, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg11, AHook, 11, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg12, AHook, 12, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg12, AHook, 12, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg13, AHook, 13, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg13, AHook, 13, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg14, AHook, 14, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg14, AHook, 14, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg15, AHook, 15, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg15, AHook, 15, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg16, AHook, 16, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg16, AHook, 16, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg17, AHook, 17, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg17, AHook, 17, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg18, AHook, 18, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg18, AHook, 18, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(ObjTestTarget, AHookObj, @TTestTarget.ObjTestTarget_reg19, AHook, 19, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(ObjTestTarget, @TTestTarget.ObjTestTarget_reg19, AHook, 19, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg0, AHook, 0, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg0, AHook, 0, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg1, AHook, 1, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg1, AHook, 1, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg2, AHook, 2, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg2, AHook, 2, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg3, AHook, 3, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg3, AHook, 3, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg4, AHook, 4, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg4, AHook, 4, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg5, AHook, 5, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg5, AHook, 5, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg6, AHook, 6, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg6, AHook, 6, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg7, AHook, 7, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg7, AHook, 7, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg8, AHook, 8, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg8, AHook, 8, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg9, AHook, 9, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg9, AHook, 9, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg10, AHook, 10, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg10, AHook, 10, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg11, AHook, 11, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg11, AHook, 11, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg12, AHook, 12, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg12, AHook, 12, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg13, AHook, 13, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg13, AHook, 13, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg14, AHook, 14, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg14, AHook, 14, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg15, AHook, 15, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg15, AHook, 15, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg16, AHook, 16, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg16, AHook, 16, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg17, AHook, 17, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg17, AHook, 17, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg18, AHook, 18, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg18, AHook, 18, AExtraParams, AExtraParamCount, 0);

  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, ACC);
  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(nil, AHookObj, @GTestTarget_reg19, AHook, 19, AExtraParams, AExtraParamCount, 0)
  else GCodeHookHelper.HookWithGlobalMethodExtra(nil, @GTestTarget_reg19, AHook, 19, AExtraParams, AExtraParamCount, 0);

end;
procedure TestCaseTargetUnhook;
begin
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg0);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg1);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg2);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg3);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg4);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg5);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg6);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg7);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg8);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg9);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg10);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg11);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg12);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg13);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg14);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg15);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg16);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg17);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg18);
  GCodeHookHelper.UnhookTarget(@TTestTarget.ObjTestTarget_reg19);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg0);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg1);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg2);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg3);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg4);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg5);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg6);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg7);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg8);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg9);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg10);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg11);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg12);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg13);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg14);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg15);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg16);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg17);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg18);
  GCodeHookHelper.UnhookTarget(@GTestTarget_reg19);
end;
procedure TestCaseRun;
begin
  TestCaseTargetHook(ObjTestHook, @TTestHook.ObjTestHook_reg0, HCC_REGISTER, @ExtraParams[0], 0);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(ObjTestHook, @TTestHook.ObjTestHook_reg1, HCC_REGISTER, @ExtraParams[0], 1);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(ObjTestHook, @TTestHook.ObjTestHook_reg2, HCC_REGISTER, @ExtraParams[0], 2);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(ObjTestHook, @TTestHook.ObjTestHook_reg3, HCC_REGISTER, @ExtraParams[0], 3);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(ObjTestHook, @TTestHook.ObjTestHook_reg4, HCC_REGISTER, @ExtraParams[0], 4);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(ObjTestHook, @TTestHook.ObjTestHook_reg5, HCC_REGISTER, @ExtraParams[0], 5);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(ObjTestHook, @TTestHook.ObjTestHook_reg6, HCC_REGISTER, @ExtraParams[0], 6);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(ObjTestHook, @TTestHook.ObjTestHook_reg7, HCC_REGISTER, @ExtraParams[0], 7);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(ObjTestHook, @TTestHook.ObjTestHook_reg8, HCC_REGISTER, @ExtraParams[0], 8);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(ObjTestHook, @TTestHook.ObjTestHook_reg9, HCC_REGISTER, @ExtraParams[0], 9);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(nil, @GTestHook_reg0, HCC_REGISTER, @ExtraParams[0], 0);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(nil, @GTestHook_reg1, HCC_REGISTER, @ExtraParams[0], 1);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(nil, @GTestHook_reg2, HCC_REGISTER, @ExtraParams[0], 2);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(nil, @GTestHook_reg3, HCC_REGISTER, @ExtraParams[0], 3);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(nil, @GTestHook_reg4, HCC_REGISTER, @ExtraParams[0], 4);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(nil, @GTestHook_reg5, HCC_REGISTER, @ExtraParams[0], 5);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(nil, @GTestHook_reg6, HCC_REGISTER, @ExtraParams[0], 6);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(nil, @GTestHook_reg7, HCC_REGISTER, @ExtraParams[0], 7);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(nil, @GTestHook_reg8, HCC_REGISTER, @ExtraParams[0], 8);
  TestCaseExecute;
  TestCaseTargetUnhook;
  TestCaseTargetHook(nil, @GTestHook_reg9, HCC_REGISTER, @ExtraParams[0], 9);
  TestCaseExecute;
  TestCaseTargetUnhook;
end;
{#@Functions}

procedure DoTestCase;
var
  I: Integer;
begin
  for I := Low(ExtraParams) to High(ExtraParams) do
    ExtraParams[I] := I;

  ObjTestTarget := TTestTarget.Create;
  ObjTestHook := TTestHook.Create;
  try
    TestCaseRun;
  finally
    ObjTestHook.Free;
    ObjTestTarget.Free;
  end;
end;

end.


