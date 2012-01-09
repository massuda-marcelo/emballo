unit Emballo.DynamicProxy.HookManager;

interface

uses
  Rtti,
  Emballo.DynamicProxy.InvokationHandler;

procedure HookMethod(var RttiContext: TRttiContext; const Instance: TObject;
  const Method: TRttiMethod; const InvokationHandler: TInvokationHandlerAnonMethod);

implementation

uses
  BeaEngineDelphi32,
  SysUtils,
  Windows,
  Emballo.RuntimeCodeGeneration.AsmBlock,
  Emballo.DynamicProxy.MethodImpl;

type
  THookRecord = record
    OverwrittenCode: TAsmBlock;
    Stub: TAsmBlock;
    MethodImpl: TMethodImpl;
    NumberOfBytesOverwritten: Integer;
  end;

function GetAddress(Dis: TDISASM): Pointer;
var
  Str: AnsiString;
begin
  Str := Trim(AnsiString(Dis.Argument1.ArgMnemonic));
  SetLength(Str, Length(Str) - 1); // Remove the 'h' suffix
  Result := Pointer(StrToInt('$' + Str));
end;

procedure HookMethod(var RttiContext: TRttiContext; const Instance: TObject;
  const Method: TRttiMethod; const InvokationHandler: TInvokationHandlerAnonMethod);
var
  Rec: THookRecord;
  Handler: TInvokationHandlerAnonMethod;
  Dis: TDISASM;
  InstructionLength: Integer;
  Instruction: AnsiString;
  InstructionByte: PByte;
  OldProtect: Cardinal;
  i: Integer;
begin
  Handler := procedure(const Method: TRttiMethod;
    const Self: TValue; const Parameters: TArray<IParameter>; const Result: IParameter)
  begin
    InvokationHandler(Method, Self, Parameters, Result);
  end;

  Rec.MethodImpl := TMethodImpl.Create(RttiContext, Method, Handler);

  Rec.Stub := TAsmBlock.Create;
  FillChar(Dis, SizeOf(TDISASM), #0);
  Dis.EIP := Integer(Method.CodeAddress);
  Rec.NumberOfBytesOverwritten := 0;
  while Rec.NumberOfBytesOverwritten < 5 do
  begin
    InstructionLength := Disasm(Dis);
    Instruction := Trim(AnsiString(Dis.Instruction.Mnemonic));
    if Instruction = 'call' then
      Rec.Stub.GenCall(GetAddress(Dis))
    else if Instruction = 'jmp' then
      Rec.Stub.GenJmp(GetAddress(Dis))
    else
    begin
      InstructionByte := PByte(Dis.EIP);
      for i := 1 to InstructionLength do
      begin
        Rec.Stub.PutB(InstructionByte^);
        Inc(InstructionByte);
      end;
    end;
    Inc(Dis.EIP, InstructionLength);
    Inc(Rec.NumberOfBytesOverwritten, InstructionLength);
  end;
  Rec.Stub.GenCall(Rec.MethodImpl.CodeAddress);
  Rec.Stub.GenJmp(Pointer(Dis.EIP));
  Rec.Stub.Compile;

  Win32Check(VirtualProtect(Method.CodeAddress, Rec.NumberOfBytesOverwritten, PAGE_READWRITE, OldProtect));
  try
    { Fill the beginning of the function with NOP }
    FillChar(Method.CodeAddress^, Rec.NumberOfBytesOverwritten, $90);
    Rec.OverwrittenCode := TAsmBlock.Create;
    Rec.OverwrittenCode.GenJmp(Rec.Stub.Block);
    Rec.OverwrittenCode.Compile(Method.CodeAddress);
  finally
    Win32Check(VirtualProtect(Method.CodeAddress, Rec.NumberOfBytesOverwritten, OldProtect, OldProtect));
  end;
end;

end.
