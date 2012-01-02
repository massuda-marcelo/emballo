unit Emballo.DITests;

interface

uses
  TestFramework, Emballo.DI, SysUtils, Rtti;

type
  TDelegateModule = class(TModule)
  public
    FDelegate: TProc;
    procedure Configure; override;
  end;

  TTestModule = class(TModule)
  public
    procedure Configure; override;
  end;

  TInjectorImplTests = class(TTestCase)
  private
    FCtx: TRttiContext;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ShouldConfigureAllModulesOnInjectorCreation;
    procedure GetInstance;
    procedure TestScope;
    procedure TestInterfaceDependencyShouldRemainAliveAsLongAsMainInstanceIsAlive;
  end;

  TMyScope = class(TScope)
  protected
    function Get(const Info: TRttiType): TValue; override;
    procedure NotifyCreation(const RequestedType: TRttiType;
      const Value: TValue); override;
  end;

  TDelegateScope = class(TScope)
  type
    TGet = reference to function(const Info: TRttiType): TValue;
  class var
    FGet: TGet;
  protected
    function Get(const Info: TRttiType): TValue; override;
    procedure NotifyCreation(const RequestedType: TRttiType;
      const Value: TValue); override;
  end;

  IBar = interface
    ['{22081868-7E42-4429-A8BD-2CB485E35CE0}']
  end;

  TBar = class(TInterfacedObject, IBar)
  public
    destructor Destroy; override;
  end;

  TAbstractFoo = class

  end;

  TConcreteFoo = class(TAbstractFoo)
  public
    PointerToBar: Pointer;
    constructor Create(Bar: IBar);
  end;

implementation

uses
  Emballo.Rtti;

var
  BarDestroyed: Boolean;

function Delegate(const Proc: TProc): TDelegateModule;
begin
  Result := TDelegateModule.Create;
  Result.FDelegate := Proc;
end;

{ TTestModule }

procedure TTestModule.Configure;
begin
  inherited;
  Bind(TAbstractFoo).ToType(TConcreteFoo);
  Bind(IBar).ToType(TBar).InScope(TMyScope);
end;

{ TInjectorImplTests }

procedure TInjectorImplTests.GetInstance;
var
  Injector: IInjector;
  Ctx: TRttiContext;
  Bar: IInterface;
  Obj: TObject;
begin
  Injector := TInjectorImpl.Create([TTestModule.Create]);

  Ctx := TRttiContext.Create;
  try
    Obj := Injector.GetInstance(Ctx.GetType(TAbstractFoo)).AsObject;
    try
      CheckTrue(Obj.InheritsFrom(TConcreteFoo));
    finally
      Obj.Free;
    end;

    Bar := Injector.GetInstance(Ctx.GetType(TypeInfo(IBar))).AsInterface;
    CheckTrue(TObject(Bar).InheritsFrom(TBar));
  finally
    Ctx.Free;
  end;
end;

procedure TInjectorImplTests.SetUp;
begin
  inherited;
  FCtx := TRttiContext.Create;
end;

procedure TInjectorImplTests.ShouldConfigureAllModulesOnInjectorCreation;
var
  Injector: TInjectorImpl;
  M1, M2: TModule;
  Called1, Called2: Boolean;
begin
  Called1 := False;
  Called2 := False;
  M1 := Delegate(procedure
  begin
    Called1 := True;
  end);

  M2 := Delegate(procedure
  begin
    Called2 := True;
  end);

  Injector := TInjectorImpl.Create([M1, M2]);
  try
    CheckTrue(Called1);
    CheckTrue(Called2);
  finally
    Injector.Free;
  end;
end;

procedure TInjectorImplTests.TearDown;
begin
  inherited;
  FCtx.Free;
end;

procedure TInjectorImplTests.TestInterfaceDependencyShouldRemainAliveAsLongAsMainInstanceIsAlive;
var
  Injector: TInjector;
  Foo: TConcreteFoo;
begin
  BarDestroyed := False;
  Injector := TInjector.Create([TTestModule.Create]);
  Foo := Injector.GetInstance<TConcreteFoo>;
  try
    CheckFalse(BarDestroyed);
  finally
    Foo.Free;
  end;
  CheckTrue(BarDestroyed);

end;

procedure TInjectorImplTests.TestScope;
var
  Module: TModule;
  Injector: IInjector;
  FooInstance: TObject;
  BarInstance: IBar;
  ReturnedInstanceObj: TObject;
  ReturnedInstanceIntf: IBar;
  V: TValue;
begin
  Module := Delegate(procedure
  begin
    Module.Bind(TAbstractFoo).ToType(TConcreteFoo).InScope(TDelegateScope);
    Module.Bind(IBar).ToType(TBar).InScope(TDelegateScope);
  end);

  Injector := TInjectorImpl.Create([Module]);

  BarInstance := TBar.Create;

  FooInstance := TConcreteFoo.Create(Nil);
  V := TValue.From(FooInstance);
  try
    TDelegateScope.FGet := function(const Info: TRttiType): TValue
    begin
      CheckEquals(TAbstractFoo, Info.AsInstance.MetaclassType);
      Result := V;
    end;

    ReturnedInstanceObj := Injector.GetInstance(FCtx.GetType(TAbstractFoo)).AsObject;
    CheckTrue(FooInstance = ReturnedInstanceObj, 'If the scope has already an instance of the requested type, that instance should be returned');

    V := TValue.From(BarInstance);
    TDelegateScope.FGet := function(const Info: TRttiType): TValue
    begin
      Result := V;
    end;

    ReturnedInstanceIntf := Injector.GetInstance(FCtx.GetType(TypeInfo(IBar))).AsInterface as IBar;
    CheckTrue(BarInstance = ReturnedInstanceIntf, 'If the scope has already an instance of the requested type, that instance should be returned');
  finally
    FooInstance.Free;
  end;
end;

{ TDelegateModule }

procedure TDelegateModule.Configure;
begin
  inherited;
  FDelegate();
end;

{ TDelegateScope }

function TDelegateScope.Get(const Info: TRttiType): TValue;
begin
  Result := FGet(Info);
end;

procedure TDelegateScope.NotifyCreation(const RequestedType: TRttiType;
  const Value: TValue);
begin
  inherited;

end;

{ TMyScope }

function TMyScope.Get(const Info: TRttiType): TValue;
begin
  Result := TValue.Empty;
end;

procedure TMyScope.NotifyCreation(const RequestedType: TRttiType;
  const Value: TValue);
begin
  inherited;

end;

{ TConcreteFoo }

constructor TConcreteFoo.Create(Bar: IBar);
begin
  { Store as a pointer so that it doesnt do ref. count. This is to test if
    the IBar instance remains alive as long as TConcreteFoo instance is alive,
    even though there isn't any explicit reference to IBar }
  PointerToBar := Pointer(Bar);
end;

{ TBar }

destructor TBar.Destroy;
begin
  BarDestroyed := True;
  inherited;
end;

initialization
RegisterTest('Emballo.DI', TInjectorImplTests.Suite);

end.
