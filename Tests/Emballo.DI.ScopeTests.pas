unit Emballo.DI.ScopeTests;

interface

uses
  TestFramework, Emballo.DI, Rtti, Emballo.Services;

type
  TScopeTests = class(TTestCase)
  published
    procedure NotifyScopeAfterObjectCreation;
  end;

  TGetDelegate = reference to function(Info: TRttiType): TValue;
  TNotifyCreationDelegate = reference to procedure(RequestedType: TRttiType;
    Value: TValue);

  TTestScope = class(TScope)
  protected
    function Get(const Info: TRttiType): TValue; override;
    procedure NotifyCreation(const RequestedType: TRttiType;
      const Value: TValue); override;
  public
    class var GetDelegate: TGetDelegate;
    class var NotifyCreationDelegate: TNotifyCreationDelegate;
  end;

  TTestModule = class(TModule)
  public
    procedure Configure; override;
  end;

  TFoo = class

  end;

implementation

{ TScopeTests }

procedure TScopeTests.NotifyScopeAfterObjectCreation;
var
  Injector: TInjector;
  Inst: TFoo;
  Called: Boolean;
  RegisteredInstance: TObject;
begin
  Called := False;
  Injector := EmballoServices.CreateInjector([TTestModule.Create]);
  TTestScope.NotifyCreationDelegate := procedure(RequestedType: TRttiType;
    Value: TValue)
  begin
    CheckEquals(TFoo, RequestedType.AsInstance.MetaclassType);
    RegisteredInstance := Value.AsObject;
    Called := True;
  end;
  Inst := Injector.GetInstance<TFoo>;
  CheckTrue(Inst = RegisteredInstance);
  Inst.Free;
  CheckTrue(Called);
end;

{ TTestScope }

function TTestScope.Get(const Info: TRttiType): TValue;
begin
  if Assigned(GetDelegate) then
    Result := GetDelegate(Info)
  else
    Result := TValue.Empty;
end;

procedure TTestScope.NotifyCreation(const RequestedType: TRttiType;
  const Value: TValue);
begin
  inherited;
  if Assigned(NotifyCreationDelegate) then
    NotifyCreationDelegate(RequestedType, Value);
end;

{ TTestModule }

procedure TTestModule.Configure;
begin
  inherited;
  Bind(TFoo).ToType(TFoo).InScope(TTestScope);
end;

initialization
RegisterTest('Emballo.DI', TScopeTests.Suite);

end.
