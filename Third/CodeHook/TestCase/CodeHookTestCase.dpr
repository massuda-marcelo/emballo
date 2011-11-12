program CodeHookTestCase;

uses
  SysUtils,
  Classes,
  Windows,
  CodeHookIntf,
  CodeHook,
  TestCase in 'TestCase.pas';

procedure MsgBox(const AMsg: string);
begin
  MessageBox(0, PChar(AMsg), 'Message', MB_OK);
end;

procedure InitWithDll;
begin
  InitCodeHookDLL('..\..\CHook.dll');
  GetCodeHook(GCodeHook);
  GCodeHook.GetCodeHookHelper(GCodeHookHelper);
end;

begin
  try
    InitWithDll;

    DoTestCase;

    MsgBox('Good');
  except
    on E: Exception do
      MessageBox(0, PChar(E.Message), 'Error', MB_OK);
  end;
end.

