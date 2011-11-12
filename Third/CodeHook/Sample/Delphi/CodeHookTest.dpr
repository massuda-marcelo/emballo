program CodeHookTest;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  SysUtils,
  Classes,
  Windows,
  CodeHookIntf;

type
  TObjTarget = class
  public
    function TestTarget(const AMsg: string; V: Integer): Integer;
  end;

  TObjHook = class
  public
    function TestHook(AHandle: TCodeHookHandle; AParams: PCardinal): Cardinal;
  end;

  TMyUserData = packed record
    Msg: string;
  end;
  PMyUserData = ^TMyUserData;

var
  GCodeHook: ICodeHook;
  GCodeHookHelper: ICodeHookHelper;

procedure MsgBox(const AMsg: string);
begin
  MessageBox(0, PChar(AMsg), 'Message', MB_OK);
end;

procedure DoTest;
var
  lObjTarget: TObjTarget;
  lObjHook: TObjHook;
  H: TCodeHookHandle;
begin
  GCodeHook.SetUserDataSize(SizeOf(TMyUserData));
  lObjTarget := TObjTarget.Create;
  lObjHook := TObjHook.Create;
  GCodeHookHelper.SetCallingConvention(HCC_REGISTER, HCC_REGISTER);
  H := GCodeHookHelper.HookWithObjectMethod(lObjTarget, lObjHook,
    @TObjTarget.TestTarget, @TObjHook.TestHook, 2, 0);
  PMyUserData(GCodeHook.GetUserData(H))^.Msg := 'This is user data';
  lObjTarget.TestTarget('This is a test', 3);
end;

{ TObjTarget }

function TObjTarget.TestTarget(const AMsg: string; V: Integer): Integer;
begin
  (Format('%s %d', [AMsg, V]));
  Result := V * 2;
end;

{ TObjHook }

function TObjHook.TestHook(AHandle: TCodeHookHandle;
  AParams: PCardinal): Cardinal;
var
  lParams: PCodeHookParamAccessor;
  lMsg: string;
  V: Integer;
begin
  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);
  lParams := PCodeHookParamAccessor(AParams);
  lMsg := string(lParams[0]);
  V := lParams[1];
  MsgBox(Format('Msg: %s V: %d Result: %d UserData: %s', [lMsg, V, Result,
    PMyUserData(GCodeHook.GetUserData(AHandle))^.Msg]));
end;

procedure InitWithDll;
begin
  InitCodeHookDLL('..\..\..\CHook.dll');
  GetCodeHook(GCodeHook);
  GCodeHook.GetCodeHookHelper(GCodeHookHelper);
end;

begin
  try
    InitWithDll;
    DoTest;
  except
    on E: Exception do
      MessageBox(0, PChar(E.Message), 'Error', MB_OK);
  end;
end.

