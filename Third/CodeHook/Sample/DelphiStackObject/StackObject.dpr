program StackObject;

//For full featured local object allocation manager, see here,
//http://www.kbasm.com/delphi-stack-local-object.html

uses
  SysUtils,
  Classes,
  Windows,
  CodeHookIntf;

type
  TTestObject = class
  public
    procedure ShowMsg;
  end;

var
  GCodeHook: ICodeHook;
  GCodeHookHelper: ICodeHookHelper;
  GObjectBufferPtr: Pointer;

// eax - ASelf
function HookNewInstance(ASelf: TClass): TObject;
var
  P: Pointer;
begin
  if GObjectBufferPtr = nil then
    GetMem(P, ASelf.InstanceSize)
  else
    P := GObjectBufferPtr;
  Result := TObject(P);
  Result := ASelf.InitInstance(Result);
end;

procedure HookFreeInstance(ASelf: TObject);
begin
  ASelf.CleanupInstance;
  if GObjectBufferPtr = nil then
    FreeMem(Pointer(ASelf));
end;

procedure BeginStackObject;
begin
  GCodeHook.Hook(@TObject.NewInstance, @HookNewInstance);
  GCodeHook.Hook(@TObject.FreeInstance, @HookFreeInstance);
end;

procedure EndStackObject;
begin
  GCodeHookHelper.UnhookTarget(@HookNewInstance);
  GCodeHookHelper.UnhookTarget(@HookFreeInstance);
end;

procedure DoTest;
var
  lObj: TTestObject;
begin
  GObjectBufferPtr := nil;
  lObj := TTestObject.Create;
  try
    lObj.ShowMsg;
  finally
    lObj.Free;
  end;

  BeginStackObject;
  try
    asm
      sub esp, 1024
      mov GObjectBufferPtr, esp
    end;
    lObj := TTestObject.Create;
    try
      lObj.ShowMsg;
    finally
      lObj.Free;
    end;
    asm
      add esp, 1024
    end;
  finally
    EndStackObject;
  end;
end;

procedure InitWithDll;
begin
  InitCodeHookDLL('..\..\..\CHook.dll');
  GetCodeHook(GCodeHook);
  GCodeHook.GetCodeHookHelper(GCodeHookHelper);
end;

{ TTestObject }

procedure TTestObject.ShowMsg;
var
  lESP: Cardinal;
begin
  asm
    mov lESP, esp
  end;
  if (Cardinal(Self) >= lESP) and (Cardinal(Self) <= lESP + 1024) then
    MessageBox(0, 'I am in the stack', '', MB_OK)
  else
    MessageBox(0, 'I am NOT in the stack', '', MB_OK);
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

